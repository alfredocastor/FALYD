/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.falyd.dao;

import com.falyd.conexion.Conexion;
import com.falyd.modelo.Mensaje;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
/**
 *
 * @author Alfredo
 */
public class MensajeDAO {
    // 1. Guardar un nuevo mensaje en la BD
    public boolean enviarMensaje(int idEmisor, int idReceptor, String contenido) {
        boolean enviado = false;
        Connection con = null;
        PreparedStatement ps = null;

        try {
            con = Conexion.getConexion();
            // MySQL automáticamente pondrá la fecha y hora actual gracias a DEFAULT CURRENT_TIMESTAMP
            String sql = "INSERT INTO MENSAJE (id_emisor, id_receptor, contenido) VALUES (?, ?, ?)";
            ps = con.prepareStatement(sql);
            ps.setInt(1, idEmisor);
            ps.setInt(2, idReceptor);
            ps.setString(3, contenido);

            if (ps.executeUpdate() > 0) {
                enviado = true;
            }
        } catch (Exception e) {
            System.out.println("Error al enviar mensaje: " + e.getMessage());
        } finally {
            try { if (ps != null) ps.close(); if (con != null) con.close(); } catch (Exception e) {}
        }
        return enviado;
    }

    // 2. Obtener la conversación completa entre dos usuarios (ordenada por fecha)
    public List<Mensaje> obtenerConversacion(int idUsuario1, int idUsuario2) {
        List<Mensaje> lista = new ArrayList<>();
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            con = Conexion.getConexion();
            // Buscamos mensajes donde el Usuario1 le escribió al Usuario2, o viceversa.
            // Usamos DATE_FORMAT para que la hora salga bonita, ej: "09:30 AM"
            String sql = "SELECT id_mensaje, id_emisor, id_receptor, contenido, " +
                         "DATE_FORMAT(fecha_envio, '%h:%i %p') AS hora_formateada, leido " +
                         "FROM MENSAJE " +
                         "WHERE (id_emisor = ? AND id_receptor = ?) OR (id_emisor = ? AND id_receptor = ?) " +
                         "ORDER BY fecha_envio ASC";
            
            ps = con.prepareStatement(sql);
            ps.setInt(1, idUsuario1);
            ps.setInt(2, idUsuario2);
            ps.setInt(3, idUsuario2);
            ps.setInt(4, idUsuario1);
            rs = ps.executeQuery();

            while (rs.next()) {
                Mensaje m = new Mensaje();
                m.setId_mensaje(rs.getInt("id_mensaje"));
                m.setId_emisor(rs.getInt("id_emisor"));
                m.setId_receptor(rs.getInt("id_receptor"));
                m.setContenido(rs.getString("contenido"));
                m.setFecha_envio(rs.getString("hora_formateada"));
                m.setLeido(rs.getBoolean("leido"));
                lista.add(m);
            }
        } catch (Exception e) {
            System.out.println("Error al obtener conversación: " + e.getMessage());
        } finally {
            try { if (rs != null) rs.close(); if (ps != null) ps.close(); if (con != null) con.close(); } catch (Exception e) {}
        }
        return lista;
    }
}
