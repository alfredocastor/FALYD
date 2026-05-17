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
    // Método para ELIMINAR una tarea
    public boolean eliminarTarea(int idTarea) {
        boolean eliminado = false;
        Connection con = null;
        PreparedStatement ps = null;

        try {
            con = Conexion.getConexion();
            String sql = "DELETE FROM TAREA WHERE id_tarea = ?";
            ps = con.prepareStatement(sql);
            ps.setInt(1, idTarea);

            if (ps.executeUpdate() > 0) {
                eliminado = true;
            }
        } catch (Exception e) {
            System.out.println("Error al eliminar tarea: " + e.getMessage());
        } finally {
            try { if (ps != null) ps.close(); if (con != null) con.close(); } catch (Exception e) {}
        }
        return eliminado;
    }
    // 1. Obtener una sola tarea para mostrarla en el formulario de edición
    public Tarea obtenerTarea(int idTarea) {
        Tarea t = null;
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            con = Conexion.getConexion();
            String sql = "SELECT * FROM TAREA WHERE id_tarea = ?";
            ps = con.prepareStatement(sql);
            ps.setInt(1, idTarea);
            rs = ps.executeQuery();

            if (rs.next()) {
                t = new Tarea();
                t.setId_tarea(rs.getInt("id_tarea"));
                t.setTitulo(rs.getString("titulo"));
                t.setDescripcion(rs.getString("descripcion"));
                t.setFecha_entrega(rs.getString("fecha_entrega"));
                t.setId_materia(rs.getInt("id_materia"));
            }
        } catch (Exception e) {
            System.out.println("Error al obtener tarea: " + e.getMessage());
        } finally {
            try { if (rs != null) rs.close(); if (ps != null) ps.close(); if (con != null) con.close(); } catch (Exception e) {}
        }
        return t;
    }

    // 2. Actualizar los datos de la tarea en la base de datos
    public boolean actualizarTarea(int idTarea, String titulo, String descripcion, String fecha_entrega, int idMateria) {
        boolean actualizado = false;
        Connection con = null;
        PreparedStatement ps = null;

        try {
            con = Conexion.getConexion();
            String sql = "UPDATE TAREA SET titulo = ?, descripcion = ?, fecha_entrega = ?, id_materia = ? WHERE id_tarea = ?";
            ps = con.prepareStatement(sql);
            ps.setString(1, titulo);
            ps.setString(2, descripcion);
            ps.setString(3, fecha_entrega);
            ps.setInt(4, idMateria);
            ps.setInt(5, idTarea);

            if (ps.executeUpdate() > 0) {
                actualizado = true;
            }
        } catch (Exception e) {
            System.out.println("Error al actualizar tarea: " + e.getMessage());
        } finally {
            try { if (ps != null) ps.close(); if (con != null) con.close(); } catch (Exception e) {}
        }
        return actualizado;
    }
    // Listar todas las tareas asignadas en el sistema junto con el nombre de su materia
    public List<Tarea> listarTareasParaAlumno() {
        List<Tarea> lista = new ArrayList<>();
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            con = Conexion.getConexion();
            String sql = "SELECT t.*, m.nombre_materia FROM TAREA t " +
                         "INNER JOIN MATERIA m ON t.id_materia = m.id_materia " +
                         "ORDER BY t.fecha_entrega ASC";
            ps = con.prepareStatement(sql);
            rs = ps.executeQuery();

            while (rs.next()) {
                Tarea t = new Tarea();
                t.setId_tarea(rs.getInt("id_tarea"));
                t.setTitulo(rs.getString("titulo"));
                t.setDescripcion(rs.getString("descripcion"));
                t.setFecha_entrega(rs.getString("fecha_entrega"));
                t.setId_materia(rs.getInt("id_materia"));
                t.setNombre_materia(rs.getString("nombre_materia"));
                lista.add(t);
            }
        } catch (Exception e) {
            System.out.println("Error al listar tareas para alumno: " + e.getMessage());
        } finally {
            try { if (rs != null) rs.close(); if (ps != null) ps.close(); if (con != null) con.close(); } catch (Exception e) {}
        }
        return lista;
    }
}
