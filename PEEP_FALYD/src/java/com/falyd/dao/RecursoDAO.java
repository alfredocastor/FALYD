/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.falyd.dao;

import com.falyd.conexion.Conexion;
import com.falyd.modelo.Recurso;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
/**
 *
 * @author Alfredo
 */
public class RecursoDAO {
    public boolean registrarRecurso(String titulo, String descripcion, String tipo, String url, String fecha, int idUsuario, int idMateria) {
        boolean registrado = false;
        Connection con = null;
        PreparedStatement ps = null;

        try {
            con = Conexion.getConexion();
            String sql = "INSERT INTO RECURSO (titulo, descripcion, tipo_recurso, url_recurso, fecha_publicacion, id_materia, id_maestro) " +
                         "VALUES (?, ?, ?, ?, ?, ?, (SELECT id_maestro FROM MAESTRO WHERE id_usuario = ?))";
            ps = con.prepareStatement(sql);
            ps.setString(1, titulo);
            ps.setString(2, descripcion);
            ps.setString(3, tipo);
            ps.setString(4, url);
            ps.setString(5, fecha);
            ps.setInt(6, idMateria);
            ps.setInt(7, idUsuario);

            if (ps.executeUpdate() > 0) {
                registrado = true;
            }
        } catch (Exception e) {
            System.out.println("Error al registrar recurso: " + e.getMessage());
        } finally {
            try { if (ps != null) ps.close(); if (con != null) con.close(); } catch (Exception e) {}
        }
        return registrado;
    }

    public List<Recurso> listarRecursosPorMaestro(int idUsuario) {
        List<Recurso> lista = new ArrayList<>();
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            con = Conexion.getConexion();
            String sql = "SELECT r.*, m.nombre_materia FROM RECURSO r " +
                         "INNER JOIN MATERIA m ON r.id_materia = m.id_materia " +
                         "INNER JOIN MAESTRO mae ON r.id_maestro = mae.id_maestro " +
                         "WHERE mae.id_usuario = ? ORDER BY r.id_recurso DESC";
            ps = con.prepareStatement(sql);
            ps.setInt(1, idUsuario);
            rs = ps.executeQuery();

            while (rs.next()) {
                Recurso r = new Recurso();
                r.setId_recurso(rs.getInt("id_recurso"));
                r.setTitulo(rs.getString("titulo"));
                r.setDescripcion(rs.getString("descripcion"));
                r.setTipo_recurso(rs.getString("tipo_recurso"));
                r.setUrl_recurso(rs.getString("url_recurso"));
                r.setFecha_publicacion(rs.getString("fecha_publicacion"));
                r.setId_materia(rs.getInt("id_materia"));
                r.setNombre_materia(rs.getString("nombre_materia"));
                lista.add(r);
            }
        } catch (Exception e) {
            System.out.println("Error al listar recursos: " + e.getMessage());
        } finally {
            try { if (rs != null) rs.close(); if (ps != null) ps.close(); if (con != null) con.close(); } catch (Exception e) {}
        }
        return lista;
    }
}