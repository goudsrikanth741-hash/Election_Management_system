package com.univelect.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBConnection {

    public static Connection getConnection() throws SQLException {

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            throw new SQLException(
                    "MySQL JDBC driver not found in Tomcat application.",
                    e
            );
        }

        String mysqlUrl = System.getenv("MYSQL_URL");

        if (mysqlUrl == null || mysqlUrl.isBlank()) {
            throw new SQLException(
                    "MYSQL_URL environment variable is not configured."
            );
        }

        return DriverManager.getConnection(mysqlUrl);
    }
}