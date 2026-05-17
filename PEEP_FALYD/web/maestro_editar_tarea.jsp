<%@page import="com.falyd.modelo.Tarea"%>
<%@page import="com.falyd.dao.TareaDAO"%>
<%@page import="com.falyd.modelo.Materia"%>
<%@page import="com.falyd.dao.MateriaDAO"%>
<%@page import="java.util.List"%>
<%@page import="com.falyd.modelo.Usuario"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    HttpSession sesion = request.getSession();
    Usuario user = (Usuario) sesion.getAttribute("usuarioActual");

    if (user == null || !user.getTipo_usuario().equals("MAESTRO")) {
        response.sendRedirect("login.jsp");
        return;
    }

    // Obtener la tarea que vamos a editar
    int idTarea = Integer.parseInt(request.getParameter("id_tarea"));
    TareaDAO tDAO = new TareaDAO();
    Tarea tareaEditar = tDAO.obtenerTarea(idTarea);
    
    if(tareaEditar == null){
        response.sendRedirect("maestro_tareas.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Editar Tarea - FALYD</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css">
    <style>
        :root { --blue-falyd: #0b3b60; --text-main: #2b3674; --border-color: #e2e8f0; }
        body { background-color: #f4f7fe; font-family: 'Segoe UI', sans-serif; color: var(--text-main); }
        .sidebar { width: 260px; height: 100vh; position: fixed; background: white; z-index: 100; border-bottom-right-radius: 50px; }
        .nav-link { color: #8f9bba; padding: 12px 25px; font-weight: 600; margin: 4px 15px; border-radius: 10px; text-decoration: none; display: block;}
        .main-content { margin-left: 260px; padding: 30px 40px; padding-bottom: 80px;}
        .form-container { background: white; border-radius: 20px; padding: 40px; box-shadow: 0 4px 15px rgba(0,0,0,0.02); }
        .form-control, .form-select { border-radius: 10px; border: 1px solid var(--border-color); padding: 10px 15px; }
        .btn-submit { background: var(--blue-falyd); border: none; color: white; font-weight: 600; border-radius: 10px; padding: 10px 25px; }
    </style>
</head>
<body>

    <div class="sidebar d-flex flex-column">
        <div class="p-4 text-center"><img src="img/Logo.png" width="120"></div>
        <nav class="nav flex-column mt-2 flex-grow-1">
            <a class="nav-link" href="panel_maestro.jsp"><i class="bi bi-house-door-fill me-2"></i> Inicio</a>
            <a class="nav-link" href="maestro_tareas.jsp" style="background-color: #e3f2fd; color: var(--blue-falyd);"><i class="bi bi-check2-square me-2"></i> Tareas</a>
            </nav>
    </div>

    <div class="main-content">
        <div class="mb-4">
            <a href="maestro_tareas.jsp" class="text-decoration-none fw-bold text-muted">
                <i class="bi bi-arrow-left me-1"></i> Tareas <span class="mx-2">/</span> <span style="color: var(--blue-falyd);">Editar tarea</span>
            </a>
        </div>

        <div class="form-container">
            <div class="d-flex align-items-center mb-5">
                <div class="me-3" style="font-size: 2.5rem; color: var(--blue-falyd);"><i class="bi bi-pencil-square"></i></div>
                <div>
                    <h2 class="fw-bold mb-1">Editar tarea</h2>
                    <p class="text-muted mb-0">Modifica los detalles de la tarea seleccionada.</p>
                </div>
            </div>

            <form action="TareaServlet" method="POST">
                <input type="hidden" name="accion" value="editar">
                <input type="hidden" name="id_tarea" value="<%= tareaEditar.getId_tarea() %>">

                <div class="row g-4 mb-4">
                    <div class="col-md-6">
                        <label class="form-label fw-bold">Título de la tarea <span class="text-danger">*</span></label>
                        <input type="text" class="form-control" name="titulo" value="<%= tareaEditar.getTitulo() %>" required>
                    </div>
                    
                    <div class="col-md-3">
                        <label class="form-label fw-bold">Materia <span class="text-danger">*</span></label>
                        <select name="id_materia" class="form-select" required>
                            <%
                                MateriaDAO matDAO = new MateriaDAO();
                                List<Materia> misMaterias = matDAO.listarMateriasPorMaestro(user.getId_usuario());
                                for(Materia m : misMaterias) {
                            %>
                                <option value="<%= m.getId_materia() %>" <%= (m.getId_materia() == tareaEditar.getId_materia()) ? "selected" : "" %>>
                                    <%= m.getNombre_materia() %>
                                </option>
                            <% } %>
                        </select>
                    </div>

                    <div class="col-md-3">
                        <label class="form-label fw-bold">Fecha de entrega <span class="text-danger">*</span></label>
                        <input type="date" class="form-control" name="fecha_entrega" value="<%= tareaEditar.getFecha_entrega() %>" required>
                    </div>
                </div>

                <div class="mb-5">
                    <label class="form-label fw-bold">Instrucciones / Descripción <span class="text-danger">*</span></label>
                    <textarea class="form-control" name="descripcion" rows="6" required><%= tareaEditar.getDescripcion() %></textarea>
                </div>

                <div class="d-flex justify-content-end border-top pt-4">
                    <a href="maestro_tareas.jsp" class="btn btn-light border me-3 fw-bold">Cancelar</a>
                    <button type="submit" class="btn-submit"><i class="bi bi-save me-2"></i>Actualizar Tarea</button>
                </div>
            </form>
        </div>
    </div>
</body>
</html>