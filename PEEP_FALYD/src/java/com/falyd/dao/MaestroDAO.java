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
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        // Unimos MAESTRO y USUARIO para obtener el nombre real
        String sql = "SELECT m.id_maestro, u.nombre FROM MAESTRO m INNER JOIN USUARIO u ON m.id_usuario = u.id_usuario";

        try {
            con = Conexion.getConexion();
            ps = con.prepareStatement(sql);
            rs = ps.executeQuery();

            while (rs.next()) {
                Maestro prof = new Maestro();
                prof.setId_maestro(rs.getInt("id_maestro"));
                prof.setNombre(rs.getString("nombre"));
                lista.add(prof);
            }
        } catch (Exception e) {
            System.out.println("Error al listar maestros: " + e.getMessage());
        } finally {
            try {
                if(rs != null) rs.close();
                if(ps != null) ps.close();
                if(con != null) con.close();
            } catch (Exception e) {}
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
    
}
