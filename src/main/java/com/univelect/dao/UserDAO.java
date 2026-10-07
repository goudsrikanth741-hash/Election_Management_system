package com.univelect.dao;

import com.univelect.model.User;
import com.univelect.util.DBConnection;
import com.univelect.util.PasswordUtil;

import java.sql.*;

public class UserDAO {
    public User authenticate(String identifier, String password) throws SQLException {
        String sql = "SELECT id, student_id, name, email, department, year, role, avatar, title FROM users WHERE (LOWER(student_id)=LOWER(?) OR LOWER(email)=LOWER(?)) AND password_hash=? AND status='ACTIVE'";
        try (Connection c = DBConnection.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            String hash = PasswordUtil.sha256(password);
            ps.setString(1, identifier); ps.setString(2, identifier); ps.setString(3, hash);
            try (ResultSet rs = ps.executeQuery()) { return rs.next() ? map(rs) : null; }
        }
    }
    public User findById(int id) throws SQLException {
        String sql = "SELECT id, student_id, name, email, department, year, role, avatar, title FROM users WHERE id=?";
        try (Connection c=DBConnection.getConnection(); PreparedStatement ps=c.prepareStatement(sql)) { ps.setInt(1,id); try(ResultSet rs=ps.executeQuery()){return rs.next()?map(rs):null;} }
    }
    private User map(ResultSet rs) throws SQLException { return new User(rs.getInt("id"),rs.getString("student_id"),rs.getString("name"),rs.getString("email"),rs.getString("department"),rs.getInt("year"),rs.getString("role"),rs.getString("avatar"),rs.getString("title")); }
}
