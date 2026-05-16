/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.falyd.dao;

import com.falyd.conexion.Conexion;
import com.falyd.modelo.Tarea;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

/**
 *
 * @author Alfredo
 */
public class TareaDAO {
    // Método para GUARDAR la tarea en la Base de Datos
    public boolean registrarTarea(String titulo, String descripcion, String fecha_entrega, int id_usuario, int id_materia) {
        boolean registrado = false;
        Connection con = null;
        PreparedStatement ps = null;

        try {
            con = Conexion.getConexion();
            // Insertamos la tarea y usamos una subconsulta para encontrar el id_maestro basado en el id_usuario
            String sql = "INSERT INTO TAREA (titulo, descripcion, fecha_entrega, id_maestro, id_materia) " +
                         "VALUES (?, ?, ?, (SELECT id_maestro FROM MAESTRO WHERE id_usuario = ?), ?)";
            ps = con.prepareStatement(sql);
            ps.setString(1, titulo);
            ps.setString(2, descripcion);
            ps.setString(3, fecha_entrega);
            ps.setInt(4, id_usuario);
            ps.setInt(5, id_materia);

            if (ps.executeUpdate() > 0) {
                registrado = true;
            }
        } catch (Exception e) {
            System.out.println("Error al registrar tarea: " + e.getMessage());
        } finally {
            try { if (ps != null) ps.close(); if (con != null) con.close(); } catch (Exception e) {}
        }
        return registrado;
    }

    // Método para LISTAR las tareas que ha creado el maestro que inició sesión
    public List<Tarea> listarTareasPorMaestro(int idUsuario) {
        List<Tarea> lista = new ArrayList<>();
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            con = Conexion.getConexion();
            String sql = "SELECT t.id_tarea, t.titulo, t.descripcion, t.fecha_entrega, m.nombre_materia " +
                         "FROM TAREA t " +
                         "INNER JOIN MATERIA m ON t.id_materia = m.id_materia " +
                         "INNER JOIN MAESTRO mae ON t.id_maestro = mae.id_maestro " +
                         "WHERE mae.id_usuario = ? " +
                         "ORDER BY t.fecha_entrega ASC";
            
            ps = con.prepareStatement(sql);
            ps.setInt(1, idUsuario);
            rs = ps.executeQuery();

            while (rs.next()) {
                Tarea t = new Tarea();
                t.setId_tarea(rs.getInt("id_tarea"));
                t.setTitulo(rs.getString("titulo"));
                t.setDescripcion(rs.getString("descripcion"));
                t.setFecha_entrega(rs.getString("fecha_entrega"));
                t.setNombre_materia(rs.getString("nombre_materia"));
                lista.add(t);
            }
        } catch (Exception e) {
            System.out.println("Error al listar tareas: " + e.getMessage());
        } finally {
            try { if (rs != null) rs.close(); if (ps != null) ps.close(); if (con != null) con.close(); } catch (Exception e) {}
        }
        return lista;
    }
}
