/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package com.falyd.controlador;

import com.falyd.dao.GrupoDAO;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 *
 * @author Alfredo
 */
public class GrupoServlet extends HttpServlet {
@Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Configuramos UTF-8 para evitar problemas con símbolos como el "º" (ej. 1º A)
        request.setCharacterEncoding("UTF-8");
        
        String accion = request.getParameter("accion");
        GrupoDAO dao = new GrupoDAO();

        if ("agregar".equals(accion)) {
            String nombre_grupo = request.getParameter("nombre_grupo");
            
            if (dao.agregarGrupo(nombre_grupo)) {
                response.sendRedirect("admin_grupos.jsp?msg=exito");
            } else {
                response.sendRedirect("admin_grupos.jsp?msg=error");
            }
            
        } else if ("editar".equals(accion)) {
            int id_grupo = Integer.parseInt(request.getParameter("id_grupo"));
            String nombre_grupo = request.getParameter("nombre_grupo");
            
            if (dao.editarGrupo(id_grupo, nombre_grupo)) {
                response.sendRedirect("admin_grupos.jsp?msg=editado");
            } else {
                response.sendRedirect("admin_grupos.jsp?msg=error");
            }
            
        } else if ("eliminar".equals(accion)) {
            int id_grupo = Integer.parseInt(request.getParameter("id_grupo"));
            
            if (dao.eliminarGrupo(id_grupo)) {
                response.sendRedirect("admin_grupos.jsp?msg=eliminado");
            } else {
                response.sendRedirect("admin_grupos.jsp?msg=error");
            }
        }
    }
}
