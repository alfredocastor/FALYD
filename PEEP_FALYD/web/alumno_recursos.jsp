<%@page import="com.falyd.modelo.Usuario"%>
<%@page import="com.falyd.modelo.Alumno"%>
<%@page import="com.falyd.dao.AlumnoDAO"%>
<%@page import="com.falyd.modelo.Tarea"%>
<%@page import="com.falyd.dao.TareaDAO"%>
<%@page import="com.falyd.modelo.Recurso"%>
<%@page import="com.falyd.dao.RecursoDAO"%>
<%@page import="com.falyd.modelo.Materia"%>
<%@page import="com.falyd.dao.MateriaDAO"%>
<%@page import="java.time.LocalDate"%>
<%@page import="java.time.temporal.ChronoUnit"%>
<%@page import="java.util.List"%>
<%@page import="java.util.ArrayList"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    HttpSession sesion = request.getSession();
    Usuario user = (Usuario) sesion.getAttribute("usuarioActual");

    if (user == null || !user.getTipo_usuario().equals("ALUMNO")) {
        response.sendRedirect("login.jsp");
        return;
    }

    // 1. Perfil del alumno
    AlumnoDAO aDAO = new AlumnoDAO();
    Alumno miPerfil = aDAO.obtenerAlumnoPorUsuario(user.getId_usuario());
    String nombreGrupo = (miPerfil != null && miPerfil.getGrupo() != null) ? miPerfil.getGrupo() : "Sin grupo";

    // 2. Lógica de la Campanita (Tareas pendientes)
    TareaDAO tDAO = new TareaDAO();
List<Tarea> misTareas = tDAO.listarTareasPendientesPorAlumno(miPerfil.getId_alumno());
LocalDate hoy = LocalDate.now();
    List<Tarea> tareasPendientes = new ArrayList<>();
    for (Tarea t : misTareas) {
        if (t.getFecha_entrega() != null && !t.getFecha_entrega().isEmpty()) {
            LocalDate fechaEntrega = LocalDate.parse(t.getFecha_entrega());
            if (ChronoUnit.DAYS.between(hoy, fechaEntrega) >= 0) {
                tareasPendientes.add(t);
            }
        }
    }

    // 3. Obtener Recursos y Materias
    RecursoDAO rDAO = new RecursoDAO();
    List<Recurso> listaRecursos = rDAO.listarRecursosParaAlumno();
    
    MateriaDAO mDAO = new MateriaDAO();
    List<Materia> misMaterias = mDAO.listarMateriasGenerales();

    // Contadores para las cajas superiores
    int countDocs = 0, countVids = 0, countLinks = 0, countImgs = 0;
    for(Recurso r : listaRecursos) {
        String tipo = r.getTipo_recurso();
        if("Documento".equals(tipo) || "Presentación".equals(tipo) || "PDF".equals(tipo)) countDocs++;
        else if("Video".equals(tipo)) countVids++;
        else if("Enlace".equals(tipo)) countLinks++;
        else countImgs++;
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Recursos - Panel del Alumno</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css">
    <style>
        :root { --blue-falyd: #0b3b60; --red-falyd: #d32f2f; --bg-light: #f4f7fe; --text-main: #2b3674; --border-color: #e2e8f0; }
        body { background-color: var(--bg-light); font-family: 'Segoe UI', sans-serif; color: var(--text-main); }
        .sidebar { width: 260px; height: 100vh; position: fixed; background: white; z-index: 100; border-right: 1px solid var(--border-color); }
        .sidebar-header { padding: 20px; text-align: center; border-bottom: 1px solid var(--border-color); margin-bottom: 15px; }
        .nav-link { color: #64748b; padding: 12px 25px; font-weight: 600; margin: 4px 15px; border-radius: 10px; transition: all 0.3s; text-decoration: none; display: block; }
        .nav-link i { font-size: 1.2rem; margin-right: 12px; }
        .nav-link:hover, .nav-link.active { background-color: #e3f2fd; color: var(--blue-falyd); }
        .nav-link.text-danger { color: var(--red-falyd) !important; }
        
        .main-content { margin-left: 260px; padding: 30px 40px; }
        .card-custom { background: white; border-radius: 20px; padding: 25px; box-shadow: 0 4px 15px rgba(0,0,0,0.02); border: 1px solid #f1f5f9; }
        
        /* Cajas de resumen */
        .stat-card { border: 1px solid var(--border-color); border-radius: 15px; padding: 20px; display: flex; align-items: center; background: white; transition: 0.2s; height: 100%; }
        .stat-card:hover { transform: translateY(-3px); box-shadow: 0 5px 15px rgba(0,0,0,0.03); border-color: #cbd5e1; }
        .stat-icon { width: 55px; height: 55px; border-radius: 15px; display: flex; align-items: center; justify-content: center; font-size: 1.8rem; margin-right: 15px; color: white; }
        
        /* Lista de Recursos */
        .resource-list-item { padding: 15px 20px; border: 1px solid var(--border-color); border-radius: 15px; margin-bottom: 15px; transition: 0.2s; background: white; display: flex; align-items: center; }
        .resource-list-item:hover { border-color: #cbd5e1; box-shadow: 0 4px 10px rgba(0,0,0,0.02); }
        .file-icon { width: 50px; height: 50px; border-radius: 12px; display: flex; align-items: center; justify-content: center; font-size: 1.6rem; color: white; margin-right: 20px; }
        
        /* Botones */
        .btn-view { color: var(--text-main); border: 1px solid var(--border-color); border-radius: 8px; font-weight: 600; padding: 6px 15px; background: transparent; transition: 0.2s; text-decoration: none; display: inline-flex; align-items: center; }
        .btn-view:hover { background: #f8fafc; border-color: #cbd5e1; color: var(--text-main); }
        .btn-download { background-color: var(--blue-falyd); color: white; border: none; border-radius: 8px; font-weight: 600; padding: 6px 15px; text-decoration: none; display: inline-flex; align-items: center; transition: 0.2s; }
        .btn-download:hover { background-color: #082d4a; color: white; }

        /* Tarjetas Destacadas Inferiores */
        .feature-card { background: #f8fafc; border-radius: 15px; padding: 25px; border: 1px solid var(--border-color); display: flex; flex-direction: column; height: 100%; transition: 0.2s;}
        .feature-card:hover { border-color: #cbd5e1; background: white; box-shadow: 0 5px 15px rgba(0,0,0,0.03); }
        .feature-img { width: 80px; height: 80px; margin-bottom: 20px; border-radius: 15px; display: flex; justify-content: center; align-items: center; font-size: 2.5rem; color: white; }
    </style>
</head>
<body>

    <div class="sidebar d-flex flex-column">
        <div class="sidebar-header">
            <img src="https://ui-avatars.com/api/?name=<%= user.getNombre() %>&background=e3f2fd&color=0b3b60" class="rounded-circle mb-2" width="60">
            <h6 class="fw-bold mb-0 text-dark"><%= user.getNombre() %></h6>
            <p class="text-muted small mb-0">Grupo: <%= nombreGrupo %></p>
        </div>
        <nav class="nav flex-column flex-grow-1">
            <a class="nav-link" href="panel_alumno.jsp"><i class="bi bi-house-door-fill"></i> Inicio</a>
            <a class="nav-link" href="alumno_clases.jsp"><i class="bi bi-book-half"></i> Mis clases</a>
            <a class="nav-link" href="alumno_tareas.jsp"><i class="bi bi-check2-square"></i> Tareas</a>
            <a class="nav-link" href="alumno_calendario.jsp"><i class="bi bi-calendar3"></i> Calendario</a>
            <a class="nav-link active" href="alumno_recursos.jsp"><i class="bi bi-folder2-open"></i> Recursos</a>
            <a class="nav-link" href="alumno_calificaciones.jsp"><i class="bi bi-bar-chart-fill"></i> Calificaciones</a>
            
            <div class="mt-auto mb-4">
<a class="nav-link text-danger" href="#" data-bs-toggle="modal" data-bs-target="#modalCerrarSesion"><i class="bi bi-box-arrow-right"></i> Cerrar sesión</a>            </div>
            </div>
        </nav>
    </div>

    <div class="main-content">
        <div class="d-flex justify-content-between align-items-center mb-5">
            <div>
                <h4 class="fw-bold mb-0" style="color: var(--blue-falyd);">Sistema Web Escolar</h4>
                <p class="text-muted small mb-0">Panel del Alumno</p>
            </div>
            <div class="d-flex align-items-center bg-white p-2 rounded-pill shadow-sm border">
                
                <div class="dropdown">
                    <button class="btn btn-link text-muted p-0 me-3 position-relative" data-bs-toggle="dropdown">
                        <i class="bi bi-bell-fill fs-5"></i>
                        <% if(tareasPendientes.size() > 0) { %>
                            <span class="position-absolute top-0 start-100 translate-middle badge rounded-pill bg-danger border border-light" style="font-size: 0.65rem; padding: 4px 6px;">
                                <%= tareasPendientes.size() %>
                            </span>
                        <% } %>
                    </button>
                    <ul class="dropdown-menu dropdown-menu-end shadow border-0" style="width: 320px; border-radius: 15px; margin-top: 15px;">
                        <li><h6 class="dropdown-header fw-bold text-dark fs-6 border-bottom pb-2">Notificaciones</h6></li>
                        <% if(tareasPendientes.isEmpty()) { %>
                            <li><a class="dropdown-item py-3 small text-wrap text-muted text-center" href="#">No tienes tareas nuevas.</a></li>
                        <% } else { %>
                            <li><a class="dropdown-item py-3 small text-wrap text-muted" href="alumno_tareas.jsp"><i class="bi bi-journal-text me-2 text-primary"></i>Tienes <%= tareasPendientes.size() %> tareas pendientes.</a></li>
                        <% } %>
                    </ul>
                </div>
                <img src="https://ui-avatars.com/api/?name=<%= user.getNombre() %>&background=e3f2fd&color=0b3b60" class="rounded-circle me-2" width="40">
                <div class="me-2 lh-sm">
                    <p class="mb-0 fw-bold small"><%= user.getNombre() %></p>
                </div>
            </div>
        </div>

        <div class="mb-4">
            <h1 class="fw-bold mb-1">Recursos académicos</h1>
            <p class="text-muted mb-0">Explora materiales, guías y contenido educativo que te ayudarán en tu aprendizaje.</p>
        </div>

        <div class="d-flex justify-content-between align-items-center mb-5 gap-3">
            <div class="input-group input-group-lg shadow-sm w-50" style="border-radius: 15px; overflow: hidden;">
                <span class="input-group-text bg-white border-end-0 text-muted ps-4"><i class="bi bi-search"></i></span>
                <input type="text" id="buscadorRecursos" class="form-control border-start-0 py-3" placeholder="Buscar recurso por título..." style="font-size: 0.95rem;">
            </div>
            
            <div class="input-group shadow-sm w-25" style="border-radius: 15px; overflow: hidden;">
                <span class="input-group-text bg-white border-end-0 text-muted"><i class="bi bi-filter"></i></span>
                <select id="filtroMateria" class="form-select border-start-0 py-3 text-muted fw-bold" style="font-size: 0.95rem;">
                    <option value="todas" selected>Filtro por materia</option>
                    <% for(Materia m : misMaterias) { %>
                        <option value="<%= m.getNombre_materia() %>"><%= m.getNombre_materia() %></option>
                    <% } %>
                </select>
            </div>
        </div>

        <div class="row g-4 mb-5">
            <div class="col-md-3">
                <div class="stat-card">
                    <div class="stat-icon shadow-sm" style="background-color: #3b82f6;"><i class="bi bi-book"></i></div>
                    <div>
                        <h4 class="fw-bold mb-0 text-dark">Libros/Docs</h4>
                        <p class="text-muted small mb-0 lh-sm"><%= countDocs %> recursos</p>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="stat-card">
                    <div class="stat-icon shadow-sm" style="background-color: #ef4444;"><i class="bi bi-play-btn"></i></div>
                    <div>
                        <h4 class="fw-bold mb-0 text-dark">Videos</h4>
                        <p class="text-muted small mb-0 lh-sm"><%= countVids %> recursos</p>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="stat-card">
                    <div class="stat-icon shadow-sm" style="background-color: #10b981;"><i class="bi bi-image"></i></div>
                    <div>
                        <h4 class="fw-bold mb-0 text-dark">Imágenes</h4>
                        <p class="text-muted small mb-0 lh-sm"><%= countImgs %> recursos</p>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="stat-card">
                    <div class="stat-icon shadow-sm" style="background-color: #8b5cf6;"><i class="bi bi-link-45deg"></i></div>
                    <div>
                        <h4 class="fw-bold mb-0 text-dark">Enlaces</h4>
                        <p class="text-muted small mb-0 lh-sm"><%= countLinks %> recursos</p>
                    </div>
                </div>
            </div>
        </div>

        <div class="card-custom mb-5">
            <div class="d-flex justify-content-between align-items-center mb-4 pb-2 border-bottom">
                <h5 class="fw-bold mb-0">Recursos recientes</h5>
                <a href="#" class="text-decoration-none fw-bold small text-muted">Ver todos los recursos <i class="bi bi-chevron-right"></i></a>
            </div>

            <div id="contenedorRecursos">
                <% if(listaRecursos.isEmpty()) { %>
                    <div class="text-center py-5">
                        <i class="bi bi-folder-x text-muted" style="font-size: 3rem; opacity: 0.5;"></i>
                        <h6 class="fw-bold mt-3 text-muted">No hay recursos disponibles</h6>
                        <p class="small text-muted">Aún no se han subido materiales de apoyo.</p>
                    </div>
                <% } else { 
                    for (Recurso r : listaRecursos) {
                        String colorIcono = "#3b82f6"; // Doc azul
                        String icon = "bi-file-earmark-word";
                        if("PDF".equals(r.getTipo_recurso())) { colorIcono = "#ef4444"; icon = "bi-file-earmark-pdf"; }
                        else if("Video".equals(r.getTipo_recurso())) { colorIcono = "#ef4444"; icon = "bi-play-circle"; }
                        else if("Enlace".equals(r.getTipo_recurso())) { colorIcono = "#f59e0b"; icon = "bi-link-45deg"; }
                        else if("Imagen".equals(r.getTipo_recurso())) { colorIcono = "#10b981"; icon = "bi-image"; }
                %>
                <div class="resource-list-item" data-titulo="<%= r.getTitulo().toLowerCase() %>" data-materia="<%= r.getNombre_materia() %>">
                    <div class="file-icon shadow-sm" style="background-color: <%= colorIcono %>;"><i class="bi <%= icon %>"></i></div>
                    <div class="flex-grow-1 border-end pe-4 me-4">
                        <h6 class="fw-bold mb-1 text-dark"><%= r.getTitulo() %></h6>
                        <p class="text-muted small mb-0"><%= r.getNombre_materia() %> • <%= (r.getDescripcion() != null) ? r.getDescripcion() : "" %></p>
                    </div>
                    <div class="text-center border-end pe-4 me-4" style="width: 160px;">
                        <p class="mb-0 fw-bold text-dark small"><i class="bi bi-calendar-event me-2 text-muted"></i><%= r.getFecha_publicacion() %></p>
                        <p class="mb-0 small text-muted fw-bold"><i class="bi bi-file-earmark-text me-1"></i><%= r.getTipo_recurso() %></p>
                    </div>
                    <div class="d-flex" style="gap: 10px;">
                        <a href="<%= r.getUrl_recurso() %>" target="_blank" class="btn-view"><i class="bi bi-eye me-2"></i>Ver</a>
                        <a href="<%= r.getUrl_recurso() %>" download class="btn-download"><i class="bi bi-download me-2"></i>Descargar</a>
                    </div>
                </div>
                <% } } %>
            </div>
        </div>

        <div class="d-flex justify-content-between align-items-center mb-4">
            <h5 class="fw-bold mb-0">Recursos destacados</h5>
            <a href="#" class="text-decoration-none fw-bold small text-muted">Explorar todos <i class="bi bi-chevron-right"></i></a>
        </div>
        
        <div class="row g-4 mb-4">
            <div class="col-md-4">
                <div class="feature-card">
                    <div class="feature-img shadow-sm" style="background-color: #3b82f6;"><i class="bi bi-bookshelf"></i></div>
                    <h5 class="fw-bold text-dark mb-2">Biblioteca virtual</h5>
                    <p class="text-muted small mb-4 flex-grow-1">Accede a una gran colección de libros y documentos de lectura en línea.</p>
                    <a href="#" class="btn btn-outline-primary fw-bold" style="border-radius: 8px;">Explorar <i class="bi bi-chevron-right ms-1"></i></a>
                </div>
            </div>
            <div class="col-md-4">
                <div class="feature-card">
                    <div class="feature-img shadow-sm" style="background-color: #ef4444;"><i class="bi bi-play-btn-fill"></i></div>
                    <h5 class="fw-bold text-dark mb-2">Videos educativos</h5>
                    <p class="text-muted small mb-4 flex-grow-1">Contenido audiovisual para reforzar tus clases y temas complejos.</p>
                    <a href="#" class="btn btn-outline-danger fw-bold" style="border-radius: 8px;">Explorar <i class="bi bi-chevron-right ms-1"></i></a>
                </div>
            </div>
            <div class="col-md-4">
                <div class="feature-card">
                    <div class="feature-img shadow-sm" style="background-color: #10b981;"><i class="bi bi-file-earmark-arrow-down"></i></div>
                    <h5 class="fw-bold text-dark mb-2">Material descargable</h5>
                    <p class="text-muted small mb-4 flex-grow-1">Guías, plantillas, ejercicios y rúbricas listas para que las descargues.</p>
                    <a href="#" class="btn btn-outline-success fw-bold" style="border-radius: 8px;">Explorar <i class="bi bi-chevron-right ms-1"></i></a>
                </div>
            </div>
        </div>
    </div>
<div class="modal fade" id="modalCerrarSesion" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered" style="max-width: 380px;">
            <div class="modal-content border-0 shadow" style="border-radius: 20px;">
                <div class="modal-body text-center p-4">
                    <div class="mx-auto mb-3 d-flex align-items-center justify-content-center" style="width: 75px; height: 75px; background-color: #fee2e2; border-radius: 50%; color: #ef4444; font-size: 2.2rem;">
                        <i class="bi bi-box-arrow-right"></i>
                    </div>
                    
                    <h4 class="fw-bold mb-2" style="color: var(--text-main);">¿Cerrar sesión?</h4>
                    <p class="text-muted small mb-4 px-2">Estás a punto de cerrar sesión en el sistema. Tendrás que ingresar tus credenciales nuevamente para acceder.</p>
                    
                    <div class="d-flex justify-content-center gap-3">
                        <button type="button" class="btn fw-bold px-4 py-2 flex-grow-1" data-bs-dismiss="modal" style="border: 1px solid var(--border-color); color: var(--blue-falyd); border-radius: 10px; background: white;">Cancelar</button>
                        <a href="LogoutServlet" class="btn btn-danger fw-bold px-4 py-2 flex-grow-1" style="border-radius: 10px; background-color: #e53e3e; border: none;">Cerrar sesión</a>
                    </div>
                </div>
            </div>
        </div>
    </div>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // Lógica de JavaScript para el Buscador de Texto y el Filtro de Materia
        document.addEventListener("DOMContentLoaded", function() {
            const buscadorRecursos = document.getElementById("buscadorRecursos");
            const filtroMateria = document.getElementById("filtroMateria");
            const recursos = document.querySelectorAll(".resource-list-item");

            function filtrarRecursos() {
                const textoBuscado = buscadorRecursos.value.toLowerCase();
                const materiaSeleccionada = filtroMateria.value;

                recursos.forEach(recurso => {
                    const titulo = recurso.getAttribute("data-titulo");
                    const materia = recurso.getAttribute("data-materia");

                    const coincideTexto = titulo.includes(textoBuscado);
                    const coincideMateria = (materiaSeleccionada === "todas" || materia === materiaSeleccionada);

                    if (coincideTexto && coincideMateria) {
                        recurso.style.display = "flex";
                        recurso.classList.remove("d-none");
                    } else {
                        recurso.style.display = "none";
                        recurso.classList.add("d-none");
                    }
                });
            }

            // Escuchar cambios en ambos inputs para aplicar los filtros combinados
            if (buscadorRecursos) buscadorRecursos.addEventListener("input", filtrarRecursos);
            if (filtroMateria) filtroMateria.addEventListener("change", filtrarRecursos);
        });
        
    </script>
</body>
</html>