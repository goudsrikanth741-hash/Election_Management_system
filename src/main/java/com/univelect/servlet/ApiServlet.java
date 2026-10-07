package com.univelect.servlet;

import com.google.gson.Gson;
import com.google.gson.JsonObject;
import com.univelect.dao.*;
import com.univelect.model.User;
import com.univelect.util.DBConnection;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.*;import java.sql.*;import java.util.*;

@WebServlet("/api/*")
public class ApiServlet extends HttpServlet {
 private final Gson gson=new Gson(); private final UserDAO users=new UserDAO(); private final ElectionDAO elections=new ElectionDAO(); private final StateDAO state=new StateDAO(); private final VoteDAO votes=new VoteDAO(); private final AdminDAO admin=new AdminDAO();
 private void json(HttpServletResponse r,Object o)throws IOException{r.setContentType("application/json;charset=UTF-8");r.getWriter().write(gson.toJson(o));}
 private JsonObject body(HttpServletRequest r)throws IOException{try(Reader rd=r.getReader()){return gson.fromJson(rd,JsonObject.class);}}
 private User sessionUser(HttpServletRequest r){Object o=r.getSession().getAttribute("user");return o instanceof User?(User)o:null;}
 @Override protected void doGet(HttpServletRequest req,HttpServletResponse resp)throws IOException{String p=req.getPathInfo();try{
  if("/state".equals(p)){Map<String,Object> m=new LinkedHashMap<>();m.put("elections",elections.all());m.put("positions",state.positions());m.put("students",state.students());m.put("candidates",state.candidates());m.put("votes",state.votes());User u=sessionUser(req);m.put("currentUser",u==null?Map.of("role","guest","name","Guest Visitor"):userMap(u));json(resp,m);return;}
  if("/me".equals(p)){User u=sessionUser(req);json(resp,u==null?Map.of("role","guest","name","Guest Visitor"):userMap(u));return;}
  resp.sendError(404);
 }catch(Exception e){resp.setStatus(500);json(resp,Map.of("error",e.getMessage()==null?"Server error":e.getMessage()));}}
 @Override protected void doPost(HttpServletRequest req,HttpServletResponse resp)throws IOException{String p=req.getPathInfo();try{
  if("/login".equals(p)){JsonObject b=body(req);User u=users.authenticate(str(b,"identifier"),str(b,"password"));if(u==null){resp.setStatus(401);json(resp,Map.of("error","Invalid credentials."));return;}req.getSession(true).setAttribute("user",u);json(resp,userMap(u));return;}
  if("/logout".equals(p)){req.getSession().invalidate();json(resp,Map.of("ok",true));return;}
  if("/vote".equals(p)){User u=sessionUser(req);if(u==null||"GUEST".equalsIgnoreCase(u.role())){resp.setStatus(401);json(resp,Map.of("error","Please sign in."));return;}JsonObject b=body(req);int eid=b.get("electionId").getAsInt();Map<Integer,Integer> selections=new HashMap<>();for(var x:b.getAsJsonObject("selections").entrySet())selections.put(Integer.parseInt(x.getKey()),x.getValue().getAsInt());try(Connection c=DBConnection.getConnection()){c.setAutoCommit(false);try{List<Map<String,Object>> receipt=votes.cast(c,u.id(),eid,selections);c.commit();json(resp,Map.of("ok",true,"receipt",receipt));}catch(Exception ex){c.rollback();throw ex;}}return;}
  if("/admin/create-election".equals(p)){User u=mustUser(req);JsonObject b=body(req);admin.createElection(u.id(),str(b,"title"),str(b,"code"),str(b,"description"),str(b,"startDate"),str(b,"endDate"),b.has("voters")?b.get("voters").getAsInt():500);json(resp,Map.of("ok",true));return;}
  if("/admin/status".equals(p)){User u=mustUser(req);JsonObject b=body(req);admin.setStatus(u.id(),b.get("id").getAsInt(),str(b,"status"));json(resp,Map.of("ok",true));return;}
  if("/admin/delete-election".equals(p)){User u=mustUser(req);admin.deleteElection(u.id(),body(req).get("id").getAsInt());json(resp,Map.of("ok",true));return;}
  if("/admin/add-position".equals(p)){User u=mustUser(req);JsonObject b=body(req);admin.addPosition(u.id(),b.get("electionId").getAsInt(),str(b,"title"),str(b,"description"));json(resp,Map.of("ok",true));return;}
  if("/admin/review-candidate".equals(p)){User u=mustUser(req);JsonObject b=body(req);admin.reviewCandidate(u.id(),b.get("id").getAsInt(),str(b,"status"));json(resp,Map.of("ok",true));return;}
  if("/admin/remove-candidate".equals(p)){User u=mustUser(req);admin.removeCandidate(u.id(),body(req).get("id").getAsInt());json(resp,Map.of("ok",true));return;}
  if("/admin/add-student".equals(p)){User u=mustUser(req);JsonObject b=body(req);admin.addStudent(u.id(),str(b,"name"),str(b,"studentId"),str(b,"email"),"General Studies",1,"Student@123");json(resp,Map.of("ok",true));return;}
  if("/admin/remove-student".equals(p)){User u=mustUser(req);admin.removeStudent(u.id(),body(req).get("id").getAsInt());json(resp,Map.of("ok",true));return;}
  if("/nominate".equals(p)){User u=mustUser(req);JsonObject b=body(req);admin.nominate(u.id(),b.get("electionId").getAsInt(),b.get("positionId").getAsInt(),str(b,"manifesto"));json(resp,Map.of("ok",true));return;}
  resp.sendError(404);
 }catch(SecurityException e){resp.setStatus(403);json(resp,Map.of("error",e.getMessage()));}catch(IllegalArgumentException|IllegalStateException e){resp.setStatus(400);json(resp,Map.of("error",e.getMessage()));}catch(Exception e){resp.setStatus(500);json(resp,Map.of("error",e.getMessage()==null?"Server error":e.getMessage()));}}
 private User mustUser(HttpServletRequest req){User u=sessionUser(req);if(u==null)throw new SecurityException("Please sign in.");return u;}
 private String str(JsonObject b,String k){return b.has(k)?b.get(k).getAsString():"";}
 private Map<String,Object> userMap(User u){Map<String,Object>m=new LinkedHashMap<>();m.put("role",u.role().toLowerCase());m.put("id",u.id());m.put("studentId",u.studentId());m.put("name",u.name());m.put("email",u.email());m.put("department",u.department());m.put("year",u.year());m.put("avatar",u.avatar());m.put("title",u.title());return m;}
}
