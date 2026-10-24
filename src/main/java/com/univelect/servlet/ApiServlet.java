package com.univelect.servlet;
import com.google.gson.Gson;
import com.google.gson.JsonObject;
import com.google.gson.JsonParseException;
import com.univelect.dao.*;
import com.univelect.model.User;
import com.univelect.util.DBConnection;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.*;
import java.sql.Connection;
import java.util.*;

@WebServlet("/api/*")
public class ApiServlet extends HttpServlet {

 private final Gson gson = new Gson();
 private final UserDAO users = new UserDAO();
 private final ElectionDAO elections = new ElectionDAO();
 private final StateDAO state = new StateDAO();
 private final VoteDAO votes = new VoteDAO();
 private final AdminDAO admin = new AdminDAO();

 private void json(HttpServletResponse resp, Object data)
         throws IOException {
  resp.setContentType("application/json");
  resp.setCharacterEncoding("UTF-8");
  resp.getWriter().write(gson.toJson(data));
 }

 private JsonObject body(HttpServletRequest req) throws IOException {
  try (Reader reader = req.getReader()) {
   JsonObject result = gson.fromJson(reader, JsonObject.class);

   if (result == null) {
    throw new IllegalArgumentException(
            "Request body must contain valid JSON."
    );
   }

   return result;
  } catch (JsonParseException e) {
   throw new IllegalArgumentException("Invalid JSON request body.");
  }
 }

 private String str(JsonObject body, String key) {
  if (body == null || !body.has(key)
          || body.get(key).isJsonNull()) {
   return "";
  }
  return body.get(key).getAsString().trim();
 }

 private User sessionUser(HttpServletRequest req) {
  HttpSession session = req.getSession(false);

  if (session == null) {
   return null;
  }

  Object obj = session.getAttribute("user");
  return obj instanceof User ? (User) obj : null;
 }

 private User mustUser(HttpServletRequest req) {
  User user = sessionUser(req);

  if (user == null) {
   throw new SecurityException("Please sign in.");
  }

  return user;
 }

 private User mustAdmin(HttpServletRequest req) {
  User user = mustUser(req);

  if (!"admin".equalsIgnoreCase(user.role())) {
   throw new SecurityException("Admin access required.");
  }

  return user;
 }

 private Map<String, Object> userMap(User user) {
  Map<String, Object> map = new LinkedHashMap<>();

  map.put("role", user.role().toLowerCase(Locale.ROOT));
  map.put("id", user.id());
  map.put("studentId", user.studentId());
  map.put("name", user.name());
  map.put("email", user.email());
  map.put("department", user.department());
  map.put("year", user.year());
  map.put("avatar", user.avatar());
  map.put("title", user.title());

  return map;
 }

 private Map<String, Object> guestMap() {
  Map<String, Object> map = new LinkedHashMap<>();
  map.put("role", "guest");
  map.put("name", "Guest Visitor");
  return map;
 }

 @Override
 protected void doGet(HttpServletRequest req,
                      HttpServletResponse resp) throws IOException {
  String path = req.getPathInfo();

  try {
   if ("/state".equals(path)) {
    Map<String, Object> map = new LinkedHashMap<>();

    map.put("elections", elections.all());
    map.put("positions", state.positions());
    map.put("students", state.students());
    map.put("candidates", state.candidates());
    map.put("votes", state.votes());

    User user = sessionUser(req);
    map.put("currentUser",
            user == null ? guestMap() : userMap(user));

    json(resp, map);
    return;
   }

   if ("/me".equals(path)) {
    User user = sessionUser(req);
    json(resp, user == null ? guestMap() : userMap(user));
    return;
   }

   resp.sendError(HttpServletResponse.SC_NOT_FOUND);

  } catch (Exception e) {
   handleError(resp, e);
  }
 }

 @Override
 protected void doPost(HttpServletRequest req,
                       HttpServletResponse resp) throws IOException {
  String path = req.getPathInfo();

  try {
   if ("/login".equals(path)) {
    JsonObject data = body(req);

    User user = users.authenticate(
            str(data, "identifier"),
            str(data, "password")
    );

    if (user == null) {
     resp.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
     json(resp, Collections.singletonMap(
             "error", "Invalid credentials."
     ));
     return;
    }

    HttpSession oldSession = req.getSession(false);

    if (oldSession != null) {
     oldSession.invalidate();
    }

    req.getSession(true).setAttribute("user", user);
    json(resp, userMap(user));
    return;
   }

   if ("/logout".equals(path)) {
    HttpSession session = req.getSession(false);

    if (session != null) {
     session.invalidate();
    }

    json(resp, Collections.singletonMap("ok", true));
    return;
   }

   if ("/vote".equals(path)) {
    User user = mustUser(req);

    JsonObject data = body(req);

    if (!data.has("electionId")
            || !data.has("selections")
            || !data.get("selections").isJsonObject()) {
     throw new IllegalArgumentException(
             "Election ID and selections are required."
     );
    }

    int electionId = data.get("electionId").getAsInt();
    Map<Integer, Integer> selections = new HashMap<>();

    for (Map.Entry<String,
            com.google.gson.JsonElement> entry
            : data.getAsJsonObject("selections").entrySet()) {

     int positionId = Integer.parseInt(entry.getKey());
     int candidateId = entry.getValue().getAsInt();

     if (positionId <= 0 || candidateId <= 0) {
      throw new IllegalArgumentException(
              "Invalid position or candidate ID."
      );
     }

     selections.put(positionId, candidateId);
    }

    if (selections.isEmpty()) {
     throw new IllegalArgumentException(
             "Select at least one candidate."
     );
    }

    try (Connection connection =
                 DBConnection.getConnection()) {

     connection.setAutoCommit(false);

     try {
      List<Map<String, Object>> receipt =
              votes.cast(connection, user.id(),
                      electionId, selections);

      connection.commit();

      Map<String, Object> result =
              new LinkedHashMap<>();
      result.put("ok", true);
      result.put("receipt", receipt);

      json(resp, result);

     } catch (Exception e) {
      try {
       connection.rollback();
      } catch (Exception rollbackError) {
       e.addSuppressed(rollbackError);
      }
      throw e;
     }
    }
    return;
   }

   if ("/admin/create-election".equals(path)) {
    User user = mustAdmin(req);
    JsonObject data = body(req);

    admin.createElection(
            user.id(),
            str(data, "title"),
            str(data, "code"),
            str(data, "description"),
            str(data, "startDate"),
            str(data, "endDate"),
            data.has("voters")
                    ? data.get("voters").getAsInt() : 500
    );

    json(resp, Collections.singletonMap("ok", true));
    return;
   }

   if ("/admin/status".equals(path)) {
    User user = mustAdmin(req);
    JsonObject data = body(req);

    admin.setStatus(
            user.id(),
            data.get("id").getAsInt(),
            str(data, "status")
    );

    json(resp, Collections.singletonMap("ok", true));
    return;
   }

   if ("/admin/delete-election".equals(path)) {
    User user = mustAdmin(req);
    JsonObject data = body(req);

    admin.deleteElection(
            user.id(), data.get("id").getAsInt()
    );

    json(resp, Collections.singletonMap("ok", true));
    return;
   }

   if ("/admin/add-position".equals(path)) {
    User user = mustAdmin(req);
    JsonObject data = body(req);

    admin.addPosition(
            user.id(),
            data.get("electionId").getAsInt(),
            str(data, "title"),
            str(data, "description")
    );

    json(resp, Collections.singletonMap("ok", true));
    return;
   }

   if ("/admin/review-candidate".equals(path)) {
    User user = mustAdmin(req);
    JsonObject data = body(req);

    admin.reviewCandidate(
            user.id(),
            data.get("id").getAsInt(),
            str(data, "status")
    );

    json(resp, Collections.singletonMap("ok", true));
    return;
   }

   if ("/admin/remove-candidate".equals(path)) {
    User user = mustAdmin(req);
    JsonObject data = body(req);

    admin.removeCandidate(
            user.id(), data.get("id").getAsInt()
    );

    json(resp, Collections.singletonMap("ok", true));
    return;
   }

   if ("/admin/add-student".equals(path)) {
    User user = mustAdmin(req);
    JsonObject data = body(req);

    admin.addStudent(
            user.id(),
            str(data, "name"),
            str(data, "studentId"),
            str(data, "email"),
            "General Studies",
            1,
            "Student@123"
    );

    json(resp, Collections.singletonMap("ok", true));
    return;
   }

   if ("/admin/remove-student".equals(path)) {
    User user = mustAdmin(req);
    JsonObject data = body(req);

    admin.removeStudent(
            user.id(), data.get("id").getAsInt()
    );

    json(resp, Collections.singletonMap("ok", true));
    return;
   }

   if ("/nominate".equals(path)) {
    User user = mustUser(req);
    JsonObject data = body(req);

    admin.nominate(
            user.id(),
            data.get("electionId").getAsInt(),
            data.get("positionId").getAsInt(),
            str(data, "manifesto")
    );

    json(resp, Collections.singletonMap("ok", true));
    return;
   }

   resp.sendError(HttpServletResponse.SC_NOT_FOUND);

  } catch (SecurityException e) {
   resp.setStatus(HttpServletResponse.SC_FORBIDDEN);
   json(resp, Collections.singletonMap(
           "error", e.getMessage()
   ));

  } catch (IllegalArgumentException
           | IllegalStateException e) {
   resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
   json(resp, Collections.singletonMap(
           "error", e.getMessage()
   ));

  } catch (Exception e) {
   handleError(resp, e);
  }
 }

 private void handleError(HttpServletResponse resp,
                          Exception e) throws IOException {
  if (resp.isCommitted()) {
   return;
  }

  resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);

  // Keep internal database and server details out of API responses.
  json(resp, Collections.singletonMap(
          "error", "An internal server error occurred."
  ));

  getServletContext().log("ApiServlet request failed", e);
 }
}