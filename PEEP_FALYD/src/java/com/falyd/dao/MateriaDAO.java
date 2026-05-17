/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.falyd.dao;

import com.falyd.conexion.Conexion;
import com.falyd.modelo.Materia;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

/**
 *
 * @author Alfredo
 */
public class MateriaDAO {

    // Método para REGISTRAR una nueva materia
    public boolean registrarMateria(String nombre_materia, int id_maestro) {
        boolean registrado = false;
        Connection con = null;
        PreparedStatement ps = null;

        try {
            con = Conexion.getConexion();
            // Inserción directa basada en tu tabla MATERIA
            String sql = "INSERT INTO MATERIA (nombre_materia, id_maestro) VALUES (?, ?)";
            ps = con.prepareStatement(sql);
            ps.setString(1, nombre_materia);
            ps.setInt(2, id_maestro);

            if (ps.executeUpdate() > 0) {
                registrado = true;
            }
        } catch (Exception e) {
            System.out.println("Error al registrar materia: " + e.getMessage());
        } finally {
            try {
                if (ps != null) {
                    ps.close();
                }
                if (con != null) {
                    con.close();
                }
            } catch (Exception e) {
            }
        }
        return registrado;
    }

    // Método para LISTAR las materias en la pantalla
    public List<Materia> listarMaterias() {
        List<Materia> lista = new ArrayList<>();
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        // Hacemos JOIN con MAESTRO y USUARIO para obtener el nombre del profesor
        String sql = "SELECT m.id_materia, m.nombre_materia, m.id_maestro, u.nombre AS nombre_maestro "
                + "FROM MATERIA m "
                + "INNER JOIN MAESTRO prof ON m.id_maestro = prof.id_maestro "
                + "INNER JOIN USUARIO u ON prof.id_usuario = u.id_usuario "
                + "ORDER BY m.id_materia DESC";

        try {
            con = Conexion.getConexion();
            ps = con.prepareStatement(sql);
            rs = ps.executeQuery();

            while (rs.next()) {
                Materia mat = new Materia();
                mat.setId_materia(rs.getInt("id_materia"));
                mat.setNombre_materia(rs.getString("nombre_materia"));
                mat.setId_maestro(rs.getInt("id_maestro"));
                mat.setNombre_maestro(rs.getString("nombre_maestro"));
                lista.add(mat);
            }
        } catch (Exception e) {
            System.out.println("Error al listar materias: " + e.getMessage());
        } finally {
            try {
                if (rs != null) {
                    rs.close();
                }
                if (ps != null) {
                    ps.close();
                }
                if (con != null) {
                    con.close();
                }
            } catch (Exception e) {
            }
        }
        return lista;
    }

    // Método para ELIMINAR una materia
    public boolean eliminarMateria(int id_materia) {
        boolean eliminado = false;
        Connection con = null;
        PreparedStatement ps = null;

        try {
            con = Conexion.getConexion();
            String sql = "DELETE FROM MATERIA WHERE id_materia = ?";
            ps = con.prepareStatement(sql);
            ps.setInt(1, id_materia);

            if (ps.executeUpdate() > 0) {
                eliminado = true;
            }
        } catch (Exception e) {
            System.out.println("Error al eliminar materia: " + e.getMessage());
        } finally {
            try {
                if (ps != null) {
                    ps.close();
                }
                if (con != null) {
                    con.close();
                }
            } catch (Exception e) {
            }
        }
        return eliminado;
    }
// Método para EDITAR una materia

    public boolean editarMateria(int id_materia, String nombre_materia, int id_maestro) {
        boolean editado = false;
        Connection con = null;
        PreparedStatement ps = null;

        try {
            con = Conexion.getConexion();
            String sql = "UPDATE MATERIA SET nombre_materia = ?, id_maestro = ? WHERE id_materia = ?";
            ps = con.prepareStatement(sql);
            ps.setString(1, nombre_materia);
            ps.setInt(2, id_maestro);
            ps.setInt(3, id_materia);

            if (ps.executeUpdate() > 0) {
                editado = true;
            }
        } catch (Exception e) {
            System.out.println("Error al editar materia: " + e.getMessage());
        } finally {
            try {
                if (ps != null) {
                    ps.close();
                }
                if (con != null) {
                    con.close();
                }
            } catch (Exception e) {
            }
        }
        return editado;
    }
    public List<Materia> listarMateriasPorMaestro(int idUsuario) {
        List<Materia> lista = new ArrayList<>();
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            con = Conexion.getConexion();
            String sql = "SELECT m.id_materia, m.nombre_materia " +
                         "FROM MATERIA m " +
                         "INNER JOIN MAESTRO mae ON m.id_maestro = mae.id_maestro " +
                         "WHERE mae.id_usuario = ?";
            
            ps = con.prepareStatement(sql);
            ps.setInt(1, idUsuario);
            rs = ps.executeQuery();

            while (rs.next()) {
                Materia mat = new Materia();
                mat.setId_materia(rs.getInt("id_materia"));
                mat.setNombre_materia(rs.getString("nombre_materia"));
                lista.add(mat);
            }
        } catch (Exception e) {
            System.out.println("Error al buscar materias del maestro: " + e.getMessage());
        } finally {
            try {
                if (rs != null) { rs.close(); }
                if (ps != null) { ps.close(); }
                if (con != null) { con.close(); }
            } catch (Exception e) {
            }
        }
        return lista;
    }
    // Listar todas las materias para el panel del alumno
    public List<Materia> listarMateriasGenerales() {
        List<Materia> lista = new ArrayList<>();
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            con = Conexion.getConexion();
            // Traemos la materia y el nombre del maestro que la imparte
            String sql = "SELECT m.id_materia, m.nombre_materia, u.nombre AS nombre_maestro " +
                         "FROM MATERIA m " +
                         "LEFT JOIN MAESTRO mae ON m.id_maestro = mae.id_maestro " +
                         "LEFT JOIN USUARIO u ON mae.id_usuario = u.id_usuario";
            ps = con.prepareStatement(sql);
            rs = ps.executeQuery();

            while (rs.next()) {
                Materia m = new Materia();
                m.setId_materia(rs.getInt("id_materia"));
                m.setNombre_materia(rs.getString("nombre_materia"));
                // Usamos descripcion temporalmente para guardar el nombre del maestro en la vista
                m.setNombre_maestro(rs.getString("nombre_maestro") != null ? "Prof. " + rs.getString("nombre_maestro") : "Sin profesor asignado");
                lista.add(m);
            }
        } catch (Exception e) {
            System.out.println("Error al listar materias: " + e.getMessage());
        } finally {
            try { if (rs != null) rs.close(); if (ps != null) ps.close(); if (con != null) con.close(); } catch (Exception e) {}
        }
        return lista;
    }
}