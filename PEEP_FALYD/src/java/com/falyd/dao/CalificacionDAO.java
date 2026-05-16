/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.falyd.dao;

import com.falyd.conexion.Conexion;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
/**
 *
 * @author Alfredo
 */
public class CalificacionDAO {
    public boolean registrarCalificacion(int id_alumno, int id_tarea, double calificacion) {
        boolean registrado = false;
        Connection con = null;
        PreparedStatement ps = null;

        try {
            con = Conexion.getConexion();
            String sql = "INSERT INTO CALIFICACION (id_alumno, id_tarea, calificacion) VALUES (?, ?, ?)";
            ps = con.prepareStatement(sql);
            ps.setInt(1, id_alumno);
            ps.setInt(2, id_tarea);
            ps.setDouble(3, calificacion);

            if (ps.executeUpdate() > 0) {
                registrado = true;
            }
        } catch (Exception e) {
            System.out.println("Error al registrar calificación: " + e.getMessage());
        } finally {
            try { if (ps != null) ps.close(); if (con != null) con.close(); } catch (Exception e) {}
        }
        return registrado;
    }
    // Obtener el promedio de un alumno en una materia específica basado en sus tareas
    public double obtenerPromedioAlumnoMateria(int idAlumno, int idMateria) {
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        double promedio = -1.0; // -1 indica que el alumno no tiene tareas calificadas aún

        try {
            con = Conexion.getConexion();
            String sql = "SELECT AVG(c.calificacion) AS promedio FROM CALIFICACION c " +
                         "INNER JOIN TAREA t ON c.id_tarea = t.id_tarea " +
                         "WHERE c.id_alumno = ? AND t.id_materia = ?";
            ps = con.prepareStatement(sql);
            ps.setInt(1, idAlumno);
            ps.setInt(2, idMateria);
            rs = ps.executeQuery();
            
            if (rs.next()) {
                // Verificamos si el resultado no es nulo antes de asignar
                if (rs.getBigDecimal("promedio") != null) {
                    promedio = rs.getDouble("promedio");
                }
            }
        } catch (Exception e) {
            System.out.println("Error al obtener promedio del alumno: " + e.getMessage());
        } finally {
            try { if (rs != null) rs.close(); if (ps != null) ps.close(); if (con != null) con.close(); } catch (Exception e) {}
        }
        return promedio;
    }

    // Contar cuántas tareas tiene evaluadas un alumno en una materia
    public int contarTareasCalificadas(int idAlumno, int idMateria) {
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        int total = 0;

        try {
            con = Conexion.getConexion();
            String sql = "SELECT COUNT(*) AS total FROM CALIFICACION c " +
                         "INNER JOIN TAREA t ON c.id_tarea = t.id_tarea " +
                         "WHERE c.id_alumno = ? AND t.id_materia = ?";
            ps = con.prepareStatement(sql);
            ps.setInt(1, idAlumno);
            ps.setInt(2, idMateria);
            rs = ps.executeQuery();
            
            if (rs.next()) {
                total = rs.getInt("total");
            }
        } catch (Exception e) {
            System.out.println("Error al contar tareas calificadas: " + e.getMessage());
        } finally {
            try { if (rs != null) rs.close(); if (ps != null) ps.close(); if (con != null) con.close(); } catch (Exception e) {}
        }
        return total;
    }
}