package com.univelect.model;

public record User(int id, String studentId, String name, String email, String department, int year,
                   String role, String avatar, String title) {}
