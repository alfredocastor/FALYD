/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.falyd.dao;

import com.falyd.conexion.Conexion;
import com.falyd.modelo.Evento;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
/**
 *
 * @author Alfredo
 */
public class EventoDAO {
    public boolean registrarEvento(Evento ev, int idUsuario) {
        boolean registrado = false;
        Connection con = null;
        PreparedStatement ps = null;

        try {
            con = Conexion.getConexion();
            String sql = "INSERT INTO EVENTO (titulo, tipo_evento, descripcion, color, fecha_inicio, hora_inicio, fecha_fin, hora_fin, todo_el_dia, id_materia, id_maestro) " +
                         "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, (SELECT id_maestro FROM MAESTRO WHERE id_usuario = ?))";
            ps = con.prepareStatement(sql);
            ps.setString(1, ev.getTitulo());
            ps.setString(2, ev.getTipo_evento());
            ps.setString(3, ev.getDescription());
            ps.setString(4, ev.getColor());
            ps.setString(5, ev.getFecha_inicio());
            ps.setString(6, ev.getHora_inicio().isEmpty() ? null : ev.getHora_inicio());
            ps.setString(7, ev.getFecha_fin().isEmpty() ? null : ev.getFecha_fin());
            ps.setString(8, ev.getHora_fin().isEmpty() ? null : ev.getHora_fin());
            ps.setBoolean(9, ev.isTodo_el_dia());
            
            if(ev.getId_materia() > 0) ps.setInt(10, ev.getId_materia());
            else ps.setNull(10, java.sql.Types.INTEGER);
            
            ps.setInt(11, idUsuario);

            if (ps.executeUpdate() > 0) {
                registrado = true;
            }
        } catch (Exception e) {
            System.out.println("Error al registrar evento: " + e.getMessage());
        } finally {
            try { if (ps != null) ps.close(); if (con != null) con.close(); } catch (Exception e) {}
        }
        return registrado;
    }

    public List<Evento> listarEventosPorMaestro(int idUsuario) {
        List<Evento> lista = new ArrayList<>();
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            con = Conexion.getConexion();
            String sql = "SELECT e.*, m.nombre_materia FROM EVENTO e " +
                         "LEFT JOIN MATERIA m ON e.id_materia = m.id_materia " +
                         "INNER JOIN MAESTRO mae ON e.id_maestro = mae.id_maestro " +
                         "WHERE mae.id_usuario = ? ORDER BY e.fecha_inicio ASC, e.hora_inicio ASC";
            ps = con.prepareStatement(sql);
            ps.setInt(1, idUsuario);
            rs = ps.executeQuery();

            while (rs.next()) {
                Evento ev = new Evento();
                ev.setId_evento(rs.getInt("id_evento"));
                ev.setTitulo(rs.getString("titulo"));
                ev.setTipo_evento(rs.getString("tipo_evento"));
                ev.setDescription(rs.getString("descripcion"));
                ev.setColor(rs.getString("color"));
                ev.setFecha_inicio(rs.getString("fecha_inicio"));
                ev.getFecha_inicio();
                
                // Formatear tiempos para quitar segundos si no son nulos
                String hi = rs.getString("hora_inicio");
                ev.setHora_inicio(hi != null ? hi.substring(0, 5) : "");
                ev.setFecha_fin(rs.getString("fecha_fin") != null ? rs.getString("fecha_fin") : "");
                String hf = rs.getString("hora_fin");
                ev.setHora_fin(hf != null ? hf.substring(0, 5) : "");
                
                ev.setTodo_el_dia(rs.getBoolean("todo_el_dia"));
                ev.setId_materia(rs.getInt("id_materia"));
                ev.setNombre_materia(rs.getString("nombre_materia") != null ? rs.getString("nombre_materia") : "General");
                lista.add(ev);
            }
        } catch (Exception e) {
            System.out.println("Error al listar eventos: " + e.getMessage());
        } finally {
            try { if (rs != null) rs.close(); if (ps != null) ps.close(); if (con != null) con.close(); } catch (Exception e) {}
        }
        return lista;
    }
}