/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.falyd.dao;

import com.falyd.conexion.Conexion;
import com.falyd.modelo.Maestro;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

/**
 *
 * @author Alfredo
 */
public class MaestroDAO {
    public List<Maestro> listarMaestros() {
    List<Maestro> lista = new ArrayList<>();
    String sql = "SELECT m.id_maestro, m.id_usuario, u.nombre, u.correo " + 
             "FROM MAESTRO m " +
             "JOIN USUARIO u ON m.id_usuario = u.id_usuario";
    try (Connection con = Conexion.getConexion();
         PreparedStatement ps = con.prepareStatement(sql);
         ResultSet rs = ps.executeQuery()) {
        
        while (rs.next()) {
            Maestro m = new Maestro();
            m.setId_maestro(rs.getInt("id_maestro"));
            m.setId_usuario(rs.getInt("id_usuario"));
            m.setNombre(rs.getString("nombre"));
            m.setCorreo(rs.getString("correo")); // Guardamos el correo
            lista.add(m);
        }
    } catch (Exception e) {
        System.out.println("Error al listar maestros: " + e.getMessage());
    }
    return lista;
}
    // Método para registrar un maestro en las tablas USUARIO y MAESTRO
    public boolean registrarMaestro(String nombre, String correo, String password) {
        boolean registrado = false;
        Connection con = null;
        PreparedStatement psUsuario = null;
        PreparedStatement psMaestro = null;
        ResultSet rs = null;

        try {
            con = Conexion.getConexion();
            
            // 1. Preparamos el INSERT para la tabla USUARIO fijando el rol como 'MAESTRO'
            // Usamos RETURN_GENERATED_KEYS para atrapar el ID que MySQL le asigne
            String sqlUsuario = "INSERT INTO USUARIO (nombre, correo, password, tipo_usuario) VALUES (?, ?, ?, 'MAESTRO')";
            psUsuario = con.prepareStatement(sqlUsuario, java.sql.Statement.RETURN_GENERATED_KEYS);
            psUsuario.setString(1, nombre);
            psUsuario.setString(2, correo);
            psUsuario.setString(3, password);

            // Ejecutamos el primer INSERT
            int filasUsuario = psUsuario.executeUpdate();

            // Si el usuario se guardó bien, procedemos a registrarlo como maestro
            if (filasUsuario > 0) {
                rs = psUsuario.getGeneratedKeys(); // Obtenemos el ID de usuario
                
                if (rs.next()) {
                    int idUsuarioGenerado = rs.getInt(1);

                    // 2. Preparamos el INSERT para la tabla MAESTRO
                    String sqlMaestro = "INSERT INTO MAESTRO (id_usuario) VALUES (?)";
                    psMaestro = con.prepareStatement(sqlMaestro);
                    psMaestro.setInt(1, idUsuarioGenerado);

                    // Ejecutamos el segundo INSERT
                    int filasMaestro = psMaestro.executeUpdate();
                    if (filasMaestro > 0) {
                        registrado = true; // ¡Registro exitoso en ambas tablas!
                    }
                }
            }
        } catch (Exception e) {
            System.out.println("Error al registrar maestro en BD: " + e.getMessage());
        } finally {
            // Liberamos recursos de memoria
            try {
                if (rs != null) rs.close();
                if (psUsuario != null) psUsuario.close();
                if (psMaestro != null) psMaestro.close();
                if (con != null) con.close();
            } catch (Exception e) {
                System.out.println("Error al cerrar conexión: " + e.getMessage());
            }
        }
        
        return registrado;
    }
    // Método para EDITAR un maestro
    public boolean editarMaestro(int id_usuario, int id_maestro, String nombre, String correo, String password) {
        boolean editado = false;
        Connection con = null;
        PreparedStatement psUsuario = null;

        try {
            con = Conexion.getConexion();
            // Actualizamos la tabla USUARIO (que es donde están el nombre y correo)
            String sql;
            if (password != null && !password.trim().isEmpty()) {
                sql = "UPDATE USUARIO SET nombre = ?, correo = ?, password = ? WHERE id_usuario = ?";
                psUsuario = con.prepareStatement(sql);
                psUsuario.setString(1, nombre);
                psUsuario.setString(2, correo);
                psUsuario.setString(3, password);
                psUsuario.setInt(4, id_usuario);
            } else {
                sql = "UPDATE USUARIO SET nombre = ?, correo = ? WHERE id_usuario = ?";
                psUsuario = con.prepareStatement(sql);
                psUsuario.setString(1, nombre);
                psUsuario.setString(2, correo);
                psUsuario.setInt(3, id_usuario);
            }

            if (psUsuario.executeUpdate() > 0) {
                editado = true;
            }
        } catch (Exception e) {
            System.out.println("Error al editar maestro: " + e.getMessage());
        } finally {
            // ... (cerrar conexiones como siempre)
        }
        return editado;
    }

    // Método para ELIMINAR un maestro
    public boolean eliminarMaestro(int id_usuario, int id_maestro) {
        boolean eliminado = false;
        Connection con = null;
        PreparedStatement psMaestro = null;
        PreparedStatement psUsuario = null;

        try {
            con = Conexion.getConexion();
            // 1. Borrar de la tabla hija (MAESTRO)
            String sqlM = "DELETE FROM MAESTRO WHERE id_maestro = ?";
            psMaestro = con.prepareStatement(sqlM);
            psMaestro.setInt(1, id_maestro);
            
            if (psMaestro.executeUpdate() > 0) {
                // 2. Borrar de la tabla padre (USUARIO)
                String sqlU = "DELETE FROM USUARIO WHERE id_usuario = ?";
                psUsuario = con.prepareStatement(sqlU);
                psUsuario.setInt(1, id_usuario);
                if (psUsuario.executeUpdate() > 0) {
                    eliminado = true;
                }
            }
        } catch (Exception e) {
            System.out.println("Error al eliminar maestro: " + e.getMessage());
        } finally {
            // ... (cerrar conexiones)
        }
        return eliminado;
    }
    // Listar todos los maestros registrados con sus datos de usuario
    public List<com.falyd.modelo.Usuario> listarMaestrosContactos() {
        List<com.falyd.modelo.Usuario> lista = new ArrayList<>();
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            con = com.falyd.conexion.Conexion.getConexion();
            String sql = "SELECT u.id_usuario, u.nombre, u.correo FROM MAESTRO m " +
                         "INNER JOIN USUARIO u ON m.id_usuario = u.id_usuario ORDER BY u.nombre ASC";
            ps = con.prepareStatement(sql);
            rs = ps.executeQuery();

            while (rs.next()) {
                com.falyd.modelo.Usuario u = new com.falyd.modelo.Usuario();
                u.setId_usuario(rs.getInt("id_usuario"));
                u.setNombre(rs.getString("nombre"));
                u.setCorreo(rs.getString("correo"));
                lista.add(u);
            }
        } catch (Exception e) {
            System.out.println("Error al listar maestros contactos: " + e.getMessage());
        } finally {
            try { if (rs != null) rs.close(); if (ps != null) ps.close(); if (con != null) con.close(); } catch (Exception e) {}
        }
        return lista;
    }
    
}
