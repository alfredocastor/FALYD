/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package com.falyd.controlador;

import com.falyd.dao.MaestroDAO;
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
public class MaestroServlet extends HttpServlet {

   @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Configuramos UTF-8 para que los nombres con acentos o 'ñ' se guarden bien
        request.setCharacterEncoding("UTF-8");
        
        // Atrapamos la acción desde el formulario oculto
        String accion = request.getParameter("accion");

        if ("agregar".equals(accion)) {
            // 1. Recibimos los datos del nuevo maestro
            String nombre = request.getParameter("nombre");
            String correo = request.getParameter("correo");
            String password = request.getParameter("password");

            // 2. Pasamos los datos al DAO para la doble inserción
            MaestroDAO dao = new MaestroDAO();
            boolean exito = dao.registrarMaestro(nombre, correo, password);

            // 3. Respondemos y redirigimos a la vista del Administrador
            if (exito) {
                response.sendRedirect("panel_admin.jsp?msg=exito");
            } else {
                response.sendRedirect("panel_admin.jsp?msg=error");
            }
        }
    }
}
