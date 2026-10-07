package com.univelect.dao;
import com.univelect.util.DBConnection;
import java.sql.*;
import java.util.*;
public class ElectionDAO {
 public List<Map<String,Object>> all() throws SQLException { List<Map<String,Object>> out=new ArrayList<>(); String q="SELECT id,title,code,description,start_date,end_date,status,total_registered_voters FROM elections ORDER BY id"; try(Connection c=DBConnection.getConnection();PreparedStatement p=c.prepareStatement(q);ResultSet r=p.executeQuery()){while(r.next()){Map<String,Object> m=new LinkedHashMap<>();m.put("id",r.getInt("id"));m.put("title",r.getString("title"));m.put("code",r.getString("code"));m.put("description",r.getString("description"));m.put("startDate",r.getString("start_date"));m.put("endDate",r.getString("end_date"));m.put("status",r.getString("status"));m.put("totalRegisteredVoters",r.getInt("total_registered_voters"));out.add(m);}} return out; }
}
