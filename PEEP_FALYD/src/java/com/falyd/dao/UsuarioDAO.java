/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.falyd.dao;

import com.falyd.conexion.Conexion;
import com.falyd.modelo.Usuario;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
/**
 *
 * @author Alfredo
 */
public class UsuarioDAO {
    
    // Método para validar el login
    public Usuario validar(String correo, String pass, String tipo) {
        Usuario user = null;
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        // Consulta SQL para buscar al usuario por correo, password y tipo
        String sql = "SELECT * FROM USUARIO WHERE correo = ? AND password = ? AND tipo_usuario = ?";

        try {
            con = Conexion.getConexion();
            ps = con.prepareStatement(sql);
            ps.setString(1, correo);
            ps.setString(2, pass);
            ps.setString(3, tipo);
            rs = ps.executeQuery();

            if (rs.next()) {
                user = new Usuario();
                user.setId_usuario(rs.getInt("id_usuario"));
                user.setNombre(rs.getString("nombre"));
                user.setCorreo(rs.getString("correo"));
                user.setPassword(rs.getString("password"));
                user.setTipo_usuario(rs.getString("tipo_usuario"));
            }
        } catch (SQLException e) {
            System.out.println("Error en la validación del DAO: " + e.getMessage());
        } finally {
            // Cerramos recursos para no saturar el servidor de la escuela
            try {
                if (rs != null) rs.close();
                if (ps != null) ps.close();
                if (con != null) con.close();
            } catch (SQLException e) {
                System.out.println("Error al cerrar conexión: " + e.getMessage());
            }
        }
        return user; // Si es null, el login falló; si trae datos, el login es correcto
    }
}
