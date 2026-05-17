/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.falyd.dao;

import com.falyd.conexion.Conexion;
import com.falyd.modelo.Entrega;
import java.sql.ResultSet;
import java.sql.Connection;
import java.sql.PreparedStatement;

/**
 *
 * @author Alfredo
 */
public class EntregaDAO {
    // Método para registrar una nueva entrega de tarea en la BD
    public boolean registrarEntrega(int idTarea, int idAlumno, String archivoUrl, String comentario) {
        boolean registrado = false;
        Connection con = null;
        PreparedStatement ps = null;

        try {
            con = Conexion.getConexion();
            String sql = "INSERT INTO ENTREGA (id_tarea, id_alumno, archivo_url, comentario_alumno) VALUES (?, ?, ?, ?)";
            ps = con.prepareStatement(sql);
            ps.setInt(1, idTarea);
            ps.setInt(2, idAlumno);
            ps.setString(3, archivoUrl);
            ps.setString(4, comentario);

            if (ps.executeUpdate() > 0) {
                registrado = true;
            }
        } catch (Exception e) {
            System.out.println("Error al registrar entrega: " + e.getMessage());
        } finally {
            try { if (ps != null) ps.close(); if (con != null) con.close(); } catch (Exception e) {}
        }
        return registrado;
    }
    // Obtener la entrega específica de un alumno para una tarea
    public Entrega obtenerEntregaPorTareaYAlumno(int idTarea, int idAlumno) {
        Entrega e = null;
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            con = Conexion.getConexion();
            String sql = "SELECT ent.*, u.nombre AS nombre_alumno FROM ENTREGA ent " +
                         "INNER JOIN ALUMNO al ON ent.id_alumno = al.id_alumno " +
                         "INNER JOIN USUARIO u ON al.id_usuario = u.id_usuario " +
                         "WHERE ent.id_tarea = ? AND ent.id_alumno = ?";
            ps = con.prepareStatement(sql);
            ps.setInt(1, idTarea);
            ps.setInt(2, idAlumno);
            rs = ps.executeQuery();

            if (rs.next()) {
                e = new Entrega();
                e.setId_entrega(rs.getInt("id_entrega"));
                e.setId_tarea(rs.getInt("id_tarea"));
                e.setId_alumno(rs.getInt("id_alumno"));
                e.setArchivo_url(rs.getString("archivo_url"));
                e.setComentario_alumno(rs.getString("comentario_alumno"));
                e.setFecha_envio(rs.getString("fecha_envio"));
                e.setNombre_alumno(rs.getString("nombre_alumno"));
            }
        } catch (Exception ex) {
            System.out.println("Error al obtener entrega para el maestro: " + ex.getMessage());
        } finally {
            try { if (rs != null) rs.close(); if (ps != null) ps.close(); if (con != null) con.close(); } catch (Exception ex) {}
        }
        return e;
    }
    
}
