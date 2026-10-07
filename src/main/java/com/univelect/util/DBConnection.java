package com.univelect.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public final class DBConnection {

    private DBConnection() {}

    public static Connection getConnection() throws SQLException {

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            throw new SQLException(
                    "MySQL JDBC driver not found in Tomcat application.",
                    e
            );
        }

        String url = "jdbc:mysql://localhost:3306/univelect_db"
                + "?useSSL=false"
                + "&serverTimezone=UTC";

        String user = "root";
        String password = "8885";

        return DriverManager.getConnection(url, user, password);
    }
}