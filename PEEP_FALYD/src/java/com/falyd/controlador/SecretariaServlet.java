package com.falyd.controlador;

/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */

import com.falyd.dao.SecretariaDAO;
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
@WebServlet(urlPatterns = {"/SecretariaServlet"})
public class SecretariaServlet extends HttpServlet {
@Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        String accion = request.getParameter("accion");
        SecretariaDAO dao = new SecretariaDAO();

        if ("agregar".equals(accion)) {
            String nombre = request.getParameter("nombre");
            String correo = request.getParameter("correo");
            String password = request.getParameter("password");
            
            if (password != null && !password.trim().isEmpty()) {
                if (password.length() < 6) {
                    response.sendRedirect("admin_secretarias.jsp?error=password_corta");
                    return; // Detiene la ejecución aquí
                }
            }
            
            if (dao.agregarSecretaria(nombre, correo, password)) {
                response.sendRedirect("admin_secretarias.jsp?msg=exito");
            } else {
                response.sendRedirect("admin_secretarias.jsp?msg=error");
            }
            
        } else if ("editar".equals(accion)) {
            int id_usuario = Integer.parseInt(request.getParameter("id_usuario"));
            String nombre = request.getParameter("nombre");
            String correo = request.getParameter("correo");
            String password = request.getParameter("password"); // Puede venir vacío
            
            if (dao.editarSecretaria(id_usuario, nombre, correo, password)) {
                response.sendRedirect("admin_secretarias.jsp?msg=editado");
            } else {
                response.sendRedirect("admin_secretarias.jsp?msg=error");
            }
            
        } else if ("eliminar".equals(accion)) {
            int id_usuario = Integer.parseInt(request.getParameter("id_usuario"));
            int id_secretaria = Integer.parseInt(request.getParameter("id_secretaria"));
            
            if (dao.eliminarSecretaria(id_usuario, id_secretaria)) {
                response.sendRedirect("admin_secretarias.jsp?msg=eliminado");
            } else {
                response.sendRedirect("admin_secretarias.jsp?msg=error");
            }
        }
    }
}
