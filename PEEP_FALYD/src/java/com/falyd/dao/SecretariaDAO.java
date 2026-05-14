/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.falyd.dao;

import com.falyd.conexion.Conexion;
import com.falyd.modelo.Secretaria;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

/**
 *
 * @author Alfredo
 */
public class SecretariaDAO {
    // 1. LISTAR SECRETARIAS
    public List<Secretaria> listarSecretarias() {
        List<Secretaria> lista = new ArrayList<>();
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            con = Conexion.getConexion();
            String sql = "SELECT s.id_secretaria, s.id_usuario, u.nombre, u.correo " +
                         "FROM SECRETARIA s " +
                         "INNER JOIN USUARIO u ON s.id_usuario = u.id_usuario";
            ps = con.prepareStatement(sql);
            rs = ps.executeQuery();

            while (rs.next()) {
                Secretaria sec = new Secretaria();
                sec.setId_secretaria(rs.getInt("id_secretaria"));
                sec.setId_usuario(rs.getInt("id_usuario"));
                sec.setNombre(rs.getString("nombre"));
                sec.setCorreo(rs.getString("correo"));
                lista.add(sec);
            }
        } catch (Exception e) {
            System.out.println("Error al listar secretarias: " + e.getMessage());
        } finally {
            // Cerrar conexiones...
            try { if(rs != null) rs.close(); if(ps != null) ps.close(); if(con != null) con.close(); } catch(Exception e){}
        }
        return lista;
    }

    // 2. AGREGAR SECRETARIA (Afecta 2 tablas)
    public boolean agregarSecretaria(String nombre, String correo, String password) {
        boolean registrado = false;
        Connection con = null;
        PreparedStatement psUsuario = null;
        PreparedStatement psSecretaria = null;
        ResultSet rs = null;

        try {
            con = Conexion.getConexion();
            con.setAutoCommit(false); 

            //  Guardar en USUARIO
            String sqlUsuario = "INSERT INTO USUARIO (nombre, correo, password, tipo_usuario) VALUES (?, ?, ?, 'SECRETARIA')";
            psUsuario = con.prepareStatement(sqlUsuario, Statement.RETURN_GENERATED_KEYS);
            psUsuario.setString(1, nombre);
            psUsuario.setString(2, correo);
            psUsuario.setString(3, password);
            psUsuario.executeUpdate();

            // Obtenemos el ID del usuario recién creado
            rs = psUsuario.getGeneratedKeys();
            if (rs.next()) {
                int idUsuarioGenerado = rs.getInt(1);

                //  Guardar en SECRETARIA
                String sqlSecretaria = "INSERT INTO SECRETARIA (id_usuario) VALUES (?)";
                psSecretaria = con.prepareStatement(sqlSecretaria);
                psSecretaria.setInt(1, idUsuarioGenerado);
                psSecretaria.executeUpdate();

                // Confirmamos los cambios
                con.commit();
                registrado = true;
            }
        } catch (Exception e) {
            try { if (con != null) con.rollback(); } catch (Exception ex) {}
            System.out.println("Error al agregar secretaria: " + e.getMessage());
        } finally {
            // Cerrar conexiones...
            try { if(rs != null) rs.close(); if(psUsuario != null) psUsuario.close(); if(psSecretaria != null) psSecretaria.close(); if(con != null) { con.setAutoCommit(true); con.close(); } } catch(Exception e){}
        }
        return registrado;
    }

    // 3. EDITAR SECRETARIA
    public boolean editarSecretaria(int id_usuario, String nombre, String correo, String password) {
        boolean editado = false;
        Connection con = null;
        PreparedStatement ps = null;

        try {
            con = Conexion.getConexion();
            String sql;
            // Validamos si escribió una nueva contraseña o la dejó en blanco
            if (password != null && !password.trim().isEmpty()) {
                sql = "UPDATE USUARIO SET nombre = ?, correo = ?, password = ? WHERE id_usuario = ?";
                ps = con.prepareStatement(sql);
                ps.setString(1, nombre);
                ps.setString(2, correo);
                ps.setString(3, password);
                ps.setInt(4, id_usuario);
            } else {
                sql = "UPDATE USUARIO SET nombre = ?, correo = ? WHERE id_usuario = ?";
                ps = con.prepareStatement(sql);
                ps.setString(1, nombre);
                ps.setString(2, correo);
                ps.setInt(3, id_usuario);
            }

            if (ps.executeUpdate() > 0) {
                editado = true;
            }
        } catch (Exception e) {
            System.out.println("Error al editar secretaria: " + e.getMessage());
        } finally {
            try { if(ps != null) ps.close(); if(con != null) con.close(); } catch(Exception e){}
        }
        return editado;
    }

    // 4. ELIMINAR SECRETARIA
    public boolean eliminarSecretaria(int id_usuario, int id_secretaria) {
        boolean eliminado = false;
        Connection con = null;
        PreparedStatement psSec = null;
        PreparedStatement psUsu = null;

        try {
            con = Conexion.getConexion();
            con.setAutoCommit(false);

            // Borramos primero al "hijo" (SECRETARIA)
            String sqlSec = "DELETE FROM SECRETARIA WHERE id_secretaria = ?";
            psSec = con.prepareStatement(sqlSec);
            psSec.setInt(1, id_secretaria);
            psSec.executeUpdate();

            // Luego borramos al "padre" (USUARIO)
            String sqlUsu = "DELETE FROM USUARIO WHERE id_usuario = ?";
            psUsu = con.prepareStatement(sqlUsu);
            psUsu.setInt(1, id_usuario);
            psUsu.executeUpdate();

            con.commit();
            eliminado = true;
        } catch (Exception e) {
            try { if (con != null) con.rollback(); } catch (Exception ex) {}
            System.out.println("Error al eliminar secretaria: " + e.getMessage());
        } finally {
            try { if(psSec != null) psSec.close(); if(psUsu != null) psUsu.close(); if(con != null) { con.setAutoCommit(true); con.close(); } } catch(Exception e){}
        }
        return eliminado;
    }
}