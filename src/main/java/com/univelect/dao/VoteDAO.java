package com.univelect.dao;
import com.univelect.util.DBConnection;
import java.sql.*;import java.util.*;
public class VoteDAO {
 public boolean hasVoted(Connection c,int userId,int electionId)throws SQLException{String q="SELECT 1 FROM votes WHERE user_id=? AND election_id=? LIMIT 1";try(PreparedStatement p=c.prepareStatement(q)){p.setInt(1,userId);p.setInt(2,electionId);try(ResultSet r=p.executeQuery()){return r.next();}}}
 public List<Map<String,Object>> cast(Connection c,int userId,int electionId,Map<Integer,Integer> selections)throws SQLException{
  if(hasVoted(c,userId,electionId)) throw new IllegalStateException("You have already voted in this election.");
  String check="SELECT e.status,p.id FROM elections e JOIN positions p ON p.election_id=e.id WHERE e.id=? AND e.status='ACTIVE'";
  Set<Integer> required=new HashSet<>(); try(PreparedStatement p=c.prepareStatement(check)){p.setInt(1,electionId);try(ResultSet r=p.executeQuery()){while(r.next())required.add(r.getInt("id"));}}
  if(!required.isEmpty()&&!selections.keySet().containsAll(required)) throw new IllegalArgumentException("Please select a candidate for every available position.");
  String ins="INSERT INTO votes(user_id,election_id,position_id,candidate_id,receipt_hash) VALUES(?,?,?,?,?)"; List<Map<String,Object>> receipt=new ArrayList<>();
  try(PreparedStatement p=c.prepareStatement(ins,Statement.RETURN_GENERATED_KEYS)){
   for(var e:selections.entrySet()){
    String hash="BLT-"+UUID.randomUUID().toString().replace("-","").substring(0,8).toUpperCase();p.setInt(1,userId);p.setInt(2,electionId);p.setInt(3,e.getKey());p.setInt(4,e.getValue());p.setString(5,hash);p.addBatch();receipt.add(Map.of("positionId",e.getKey(),"candidateId",e.getValue(),"hash",hash));
   } p.executeBatch();
  }
  return receipt;
 }
}
