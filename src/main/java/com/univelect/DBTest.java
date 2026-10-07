package com.univelect;

import com.univelect.util.DBConnection;

import java.sql.Connection;

public class DBTest {
    public static void main(String[] args) {
        try (Connection connection = DBConnection.getConnection()) {
            System.out.println("================================");
            System.out.println("MYSQL CONNECTION SUCCESSFUL");
            System.out.println("Database: " + connection.getCatalog());
            System.out.println("================================");
        } catch (Exception e) {
            System.out.println("MYSQL CONNECTION FAILED");
            e.printStackTrace();
        }
    }
}