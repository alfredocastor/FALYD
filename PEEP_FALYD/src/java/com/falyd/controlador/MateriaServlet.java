/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package com.falyd.controlador;

import com.falyd.dao.MateriaDAO;
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
public class MateriaServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Soportar acentos en los nombres de las materias
        request.setCharacterEncoding("UTF-8");

        String accion = request.getParameter("accion");

        if ("agregar".equals(accion)) {
            // 1. Recibir los datos del formulario de Bootstrap
            String nombre_materia = request.getParameter("nombre_materia");
            int id_maestro = Integer.parseInt(request.getParameter("id_maestro"));
            int id_grupo = Integer.parseInt(request.getParameter("id_grupo"));

            // 2. Pasarlos al DAO
            MateriaDAO dao = new MateriaDAO();
            boolean exito = dao.registrarMateria(nombre_materia, id_maestro, id_grupo);

            // 3. Responder a la página
            if (exito) {
                response.sendRedirect("secretaria_materias.jsp?msg=exito");
            } else {
                response.sendRedirect("secretaria_materias.jsp?msg=error");
            }
        } else if ("eliminar".equals(accion)) {
            // 1. Recibimos el ID de la materia a borrar
            int id_materia = Integer.parseInt(request.getParameter("id_materia"));

            // 2. Mandamos la orden al DAO
            MateriaDAO dao = new MateriaDAO();
            boolean exito = dao.eliminarMateria(id_materia);

            // 3. Recargamos la página
            if (exito) {
                response.sendRedirect("secretaria_materias.jsp?msg=eliminado");
            } else {
                response.sendRedirect("secretaria_materias.jsp?msg=error");
            }
        } else if ("editar".equals(accion)) {
            // 1. Recibimos los datos modificados
            int id_materia = Integer.parseInt(request.getParameter("id_materia"));
            String nombre_materia = request.getParameter("nombre_materia");
            int id_maestro = Integer.parseInt(request.getParameter("id_maestro"));
            int id_grupo = Integer.parseInt(request.getParameter("id_grupo"));

            // 2. Mandamos la orden al DAO
            MateriaDAO dao = new MateriaDAO();
            boolean exito = dao.editarMateria(id_materia, nombre_materia, id_maestro,id_grupo);

            // 3. Recargamos la página
            if (exito) {
                response.sendRedirect("secretaria_materias.jsp?msg=editado");
            } else {
                response.sendRedirect("secretaria_materias.jsp?msg=error");
            }
        }
    }
}
