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
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Subir Recurso - FALYD</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css">
    <style>
        :root { --blue-falyd: #0b3b60; --red-falyd: #d32f2f; --bg-light: #f4f7fe; --text-main: #2b3674; --border-color: #e2e8f0; }
        body { background-color: var(--bg-light); font-family: 'Segoe UI', sans-serif; color: var(--text-main); }
        .sidebar { width: 260px; height: 100vh; position: fixed; background: white; z-index: 100; border-bottom-right-radius: 50px; }
        .nav-link { color: #8f9bba; padding: 12px 25px; font-weight: 600; margin: 4px 15px; border-radius: 10px; text-decoration: none; display: block; }
        .nav-link:hover, .nav-link.active { background-color: #e3f2fd; color: var(--blue-falyd); }
        .main-content { margin-left: 260px; padding: 30px 40px; padding-bottom: 80px;}
        .form-container { background: white; border-radius: 20px; padding: 40px; box-shadow: 0 4px 15px rgba(0,0,0,0.02); }
        .form-label { font-weight: 600; font-size: 0.9rem; color: var(--text-main); margin-bottom: 8px; }
        .form-control, .form-select { border-radius: 10px; border: 1px solid var(--border-color); padding: 10px 15px; }
        .type-card { border: 1px solid var(--border-color); border-radius: 12px; padding: 15px; text-align: center; cursor: pointer; transition: 0.2s; background: white; }
        .type-card:hover { border-color: var(--blue-falyd); background-color: #f8fafc; }
        .type-radio { display: none; }
        .type-radio:checked + .type-card { border-color: var(--blue-falyd); background-color: #e3f2fd; color: var(--blue-falyd); }
        .btn-submit { background: var(--blue-falyd); border: none; color: white; font-weight: 600; border-radius: 10px; padding: 10px 25px; }
    </style>
</head>
<body>

    <div class="sidebar d-flex flex-column">
        <div class="p-4 text-center"><img src="img/Logo.png" width="120"></div>
        <nav class="nav flex-column mt-2 flex-grow-1">
            <a class="nav-link" href="panel_maestro.jsp"><i class="bi bi-house-door-fill me-2"></i> Inicio</a>
            <a class="nav-link" href="maestro_tareas.jsp"><i class="bi bi-check2-square me-2"></i> Tareas</a>
            <a class="nav-link" href="maestro_calendario.jsp"><i class="bi bi-calendar3 me-2"></i> Calendario</a>
            <a class="nav-link" href="maestro_alumnos.jsp"><i class="bi bi-people-fill me-2"></i> Alumnos</a>
            <a class="nav-link" href="maestro_calificaciones.jsp"><i class="bi bi-clipboard-data me-2"></i> Calificaciones</a>
            <a class="nav-link active" href="maestro_recursos.jsp"><i class="bi bi-book me-2"></i> Recursos</a>
             <div class="mt-auto mb-4">
                <a class="nav-link text-danger" href="LogoutServlet"><i class="bi bi-box-arrow-right"></i> Cerrar sesión</a>
            </div>
        </nav>
    </div>

    <div class="main-content">
        <div class="mb-4">
            <a href="maestro_recursos.jsp" class="text-decoration-none fw-bold text-muted">
                <i class="bi bi-arrow-left me-1"></i> Recursos / <span style="color: var(--blue-falyd);">Subir recurso</span>
            </a>
        </div>

        <div class="form-container">
            <div class="d-flex align-items-center mb-5">
                <div class="me-3" style="font-size: 2.5rem; color: var(--blue-falyd);"><i class="bi bi-cloud-upload"></i></div>
                <div>
                    <h2 class="fw-bold mb-1">Subir nuevo recurso</h2>
                    <p class="text-muted mb-0">Comparte materiales y recursos educativos con tus alumnos.</p>
                </div>
            </div>

            <form action="RecursoServlet" method="POST">
                <input type="hidden" name="accion" value="subir">
                <input type="hidden" name="id_usuario_maestro" value="<%= user.getId_usuario() %>">

                <h5 class="fw-bold border-bottom pb-2 mb-4">1. Información General</h5>
                <div class="row g-4 mb-5">
                    <div class="col-md-6">
                        <label class="form-label">Título del recurso *</label>
                        <input type="text" name="titulo" class="form-control" placeholder="Ej. Guía de estudio primer parcial" required>
                    </div>
                    <div class="col-md-6">
                        <label class="form-label">Materia *</label>
                        <select name="id_materia" class="form-select" required>
                            <option value="" selected disabled>Selecciona una materia...</option>
                            <%
                                MateriaDAO matDAO = new MateriaDAO();
                                List<Materia> misMaterias = matDAO.listarMateriasPorMaestro(user.getId_usuario());
                                for(Materia m : misMaterias) {
                            %>
                                <option value="<%= m.getId_materia() %>"><%= m.getNombre_materia() %></option>
                            <% } %>
                        </select>
                    </div>
                    <div class="col-md-12">
                        <label class="form-label">Descripción (Opcional)</label>
                        <textarea name="descripcion" class="form-control" rows="3" placeholder="Escribe una breve descripción del recurso..."></textarea>
                    </div>
                </div>

                <h5 class="fw-bold border-bottom pb-2 mb-4">2. Tipo de Recurso</h5>
                <div class="row g-3 mb-5">
                    <div class="col">
                        <input type="radio" name="tipo_recurso" value="PDF" id="typePdf" class="type-radio" checked>
                        <label for="typePdf" class="w-100">
                            <div class="type-card shadow-sm"><i class="bi bi-file-earmark-pdf fs-2 d-block mb-2 text-danger"></i><span class="fw-bold small">Documento PDF</span></div>
                        </label>
                    </div>
                    <div class="col">
                        <input type="radio" name="tipo_recurso" value="Documento" id="typeDoc" class="type-radio">
                        <label for="typeDoc" class="w-100">
                            <div class="type-card shadow-sm"><i class="bi bi-file-earmark-word fs-2 d-block mb-2 text-primary"></i><span class="fw-bold small">Presentación / Word</span></div>
                        </label>
                    </div>
                    <div class="col">
                        <input type="radio" name="tipo_recurso" value="Video" id="typeVideo" class="type-radio">
                        <label for="typeVideo" class="w-100">
                            <div class="type-card shadow-sm"><i class="bi bi-play-circle fs-2 d-block mb-2 text-purple"></i><span class="fw-bold small">Video Educativo</span></div>
                        </label>
                    </div>
                    <div class="col">
                        <input type="radio" name="tipo_recurso" value="Enlace" id="typeLink" class="type-radio">
                        <label for="typeLink" class="w-100">
                            <div class="type-card shadow-sm"><i class="bi bi-link-45deg fs-2 d-block mb-2 text-warning"></i><span class="fw-bold small">Enlace Web</span></div>
                        </label>
                    </div>
                </div>

                <h5 class="fw-bold border-bottom pb-2 mb-4">3. Archivo o Enlace</h5>
                <div class="row g-4 mb-5">
                    <div class="col-md-12">
                        <label class="form-label">Dirección URL o Nombre del Archivo *</label>
                        <div class="input-group">
                            <span class="input-group-text bg-white"><i class="bi bi-link-45deg"></i></span>
                            <input type="text" name="url_recurso" class="form-control border-start-0" placeholder="https://ejemplo.com/material-estudio o archivo.pdf" required>
                        </div>
                    </div>
                </div>

                <h5 class="fw-bold border-bottom pb-2 mb-4">4. Configuración Adicional</h5>
                <div class="row g-4 mb-5">
                    <div class="col-md-6">
                        <label class="form-label">Fecha de publicación</label>
                        <input type="date" name="fecha_publicacion" class="form-control">
                    </div>
                </div>

                <div class="d-flex justify-content-end border-top pt-4">
                    <a href="maestro_recursos.jsp" class="btn btn-light border me-3 fw-bold">Cancelar</a>
                    <button type="submit" class="btn-submit"><i class="bi bi-cloud-arrow-up me-2"></i>Subir recurso</button>
                </div>
            </form>
        </div>
    </div>
</body>
</html>