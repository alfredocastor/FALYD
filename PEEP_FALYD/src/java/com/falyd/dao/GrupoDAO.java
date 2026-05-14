/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.falyd.dao;

import com.falyd.conexion.Conexion;
import com.falyd.modelo.Grupo;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
/**
 *
 * @author Alfredo
 */
public class GrupoDAO {
    // Método para LISTAR todos los grupos
    public List<Grupo> listarGrupos() {
        List<Grupo> lista = new ArrayList<>();
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            con = Conexion.getConexion();
            String sql = "SELECT * FROM GRUPO";
            ps = con.prepareStatement(sql);
            rs = ps.executeQuery();

            while (rs.next()) {
                Grupo g = new Grupo();
                g.setId_grupo(rs.getInt("id_grupo"));
                g.setNombre_grupo(rs.getString("nombre_grupo"));
                lista.add(g);
            }
        } catch (Exception e) {
            System.out.println("Error al listar grupos: " + e.getMessage());
        } finally {
            try {
                if (rs != null) rs.close();
                if (ps != null) ps.close();
                if (con != null) con.close();
            } catch (Exception e) {}
        }
        return lista;
    }

    // Método para AGREGAR un nuevo grupo
    public boolean agregarGrupo(String nombre_grupo) {
        boolean registrado = false;
        Connection con = null;
        PreparedStatement ps = null;

        try {
            con = Conexion.getConexion();
            String sql = "INSERT INTO GRUPO (nombre_grupo) VALUES (?)";
            ps = con.prepareStatement(sql);
            ps.setString(1, nombre_grupo);

            if (ps.executeUpdate() > 0) {
                registrado = true;
            }
        } catch (Exception e) {
            System.out.println("Error al agregar grupo: " + e.getMessage());
        } finally {
            try {
                if (ps != null) ps.close();
                if (con != null) con.close();
            } catch (Exception e) {}
        }
        return registrado;
    }

    // Método para ELIMINAR un grupo
    public boolean eliminarGrupo(int id_grupo) {
        boolean eliminado = false;
        Connection con = null;
        PreparedStatement ps = null;

        try {
            con = Conexion.getConexion();
            String sql = "DELETE FROM GRUPO WHERE id_grupo = ?";
            ps = con.prepareStatement(sql);
            ps.setInt(1, id_grupo);

            if (ps.executeUpdate() > 0) {
                eliminado = true;
            }
        } catch (Exception e) {
            System.out.println("Error al eliminar grupo: " + e.getMessage());
        } finally {
            try {
                if (ps != null) ps.close();
                if (con != null) con.close();
            } catch (Exception e) {}
        }
        return eliminado;
    }
// Método para EDITAR un grupo
    public boolean editarGrupo(int id_grupo, String nombre_grupo) {
        boolean editado = false;
        Connection con = null;
        PreparedStatement ps = null;

        try {
            con = Conexion.getConexion();
            String sql = "UPDATE GRUPO SET nombre_grupo = ? WHERE id_grupo = ?";
            ps = con.prepareStatement(sql);
            ps.setString(1, nombre_grupo);
            ps.setInt(2, id_grupo);

            if (ps.executeUpdate() > 0) {
                editado = true;
            }
        } catch (Exception e) {
            System.out.println("Error al editar grupo: " + e.getMessage());
        } finally {
            try {
                if (ps != null) ps.close();
                if (con != null) con.close();
            } catch (Exception e) {}
        }
        return editado;
    }
}
