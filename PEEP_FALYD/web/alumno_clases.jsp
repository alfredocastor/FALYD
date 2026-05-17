<%@page import="com.falyd.modelo.Tarea"%>
<%@page import="com.falyd.dao.TareaDAO"%>
<%@page import="com.falyd.modelo.Materia"%>
<%@page import="com.falyd.dao.MateriaDAO"%>
<%@page import="com.falyd.modelo.Alumno"%>
<%@page import="com.falyd.dao.AlumnoDAO"%>
<%@page import="java.util.List"%>
<%@page import="com.falyd.modelo.Usuario"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    HttpSession sesion = request.getSession();
    Usuario user = (Usuario) sesion.getAttribute("usuarioActual");

    if (user == null || !user.getTipo_usuario().equals("ALUMNO")) {
        response.sendRedirect("login.jsp");
        return;
    }

    // 1. Datos del perfil estudiantil
    AlumnoDAO aDAO = new AlumnoDAO();
    Alumno miPerfil = aDAO.obtenerAlumnoPorUsuario(user.getId_usuario());
    String nombreGrupo = (miPerfil != null && miPerfil.getGrupo() != null) ? miPerfil.getGrupo() : "Sin grupo";

    // 2. Cargar las clases reales de la Base de Datos
    MateriaDAO mDAO = new MateriaDAO();
    List<Materia> listaMaterias = mDAO.listarMateriasGenerales();
    
    TareaDAO tDAO = new TareaDAO();
List<Tarea> misTareas = tDAO.listarTareasPendientesPorAlumno(miPerfil.getId_alumno());
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Mis Clases - Panel del Alumno</title>
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
        
        /* Contadores estilo Dashboard */
        .icon-box { width: 45px; height: 45px; border-radius: 12px; display: flex; align-items: center; justify-content: center; font-size: 1.4rem; }
        .icon-box.blue { background-color: #e3f2fd; color: var(--blue-falyd); }
        .icon-box.green { background-color: #e8f5e9; color: #10b981; }
        .icon-box.purple { background-color: #f3e5f5; color: #8b5cf6; }
        
        /* Tarjetas de Clases */
        .class-card { background: white; border: 1px solid var(--border-color); border-radius: 15px; padding: 20px; margin-bottom: 15px; transition: 0.2s; }
        .class-card:hover { transform: translateY(-2px); box-shadow: 0 4px 12px rgba(0,0,0,0.03); border-color: #cbd5e1; }
        .subject-icon { width: 50px; height: 50px; border-radius: 12px; display: flex; align-items: center; justify-content: center; font-size: 1.6rem; color: white; margin-right: 20px; }
        .btn-outline-custom { border: 1px solid var(--border-color); color: var(--text-main); border-radius: 10px; font-weight: 600; font-size: 0.85rem; padding: 8px 16px; background: white; text-decoration: none; }
        .btn-outline-custom:hover { background-color: #f8fafc; color: var(--blue-falyd); }
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
            <a class="nav-link active" href="alumno_clases.jsp"><i class="bi bi-book-half"></i> Mis clases</a>
            <a class="nav-link" href="alumno_tareas.jsp"><i class="bi bi-check2-square"></i> Tareas</a>
            <a class="nav-link" href="alumno_calendario.jsp"><i class="bi bi-calendar3"></i> Calendario</a>
            <a class="nav-link" href="alumno_recursos.jsp"><i class="bi bi-folder2-open"></i> Recursos</a>
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
                        <% if(!misTareas.isEmpty()) { %>
                            <span class="position-absolute top-0 start-100 translate-middle badge rounded-pill bg-danger border border-light" style="font-size: 0.65rem; padding: 4px 6px;">
                                <%= misTareas.size() %>
                            </span>
                        <% } %>
                    </button>
                    <ul class="dropdown-menu dropdown-menu-end shadow border-0" style="width: 320px; border-radius: 15px; margin-top: 15px;">
                        <li><h6 class="dropdown-header fw-bold text-dark fs-6 border-bottom pb-2">Notificaciones</h6></li>
                        <% if(misTareas.isEmpty()) { %>
                            <li><a class="dropdown-item py-3 small text-wrap text-muted text-center" href="#">No tienes tareas nuevas.</a></li>
                        <% } else { %>
                            <li><a class="dropdown-item py-3 small text-wrap text-muted" href="#"><i class="bi bi-journal-text me-2 text-primary"></i>Tienes <%= misTareas.size() %> tareas pendientes de entrega.</a></li>
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
            <h1 class="fw-bold mb-1">Mis clases</h1>
            <p class="text-muted mb-0">Aquí puedes ver todas las clases en las que estás inscrito.</p>
        </div>

        <div class="row g-3 mb-5">
            <div class="col-md-4">
                <div class="card p-3 border-0 shadow-sm rounded-4 bg-white d-flex flex-row align-items-center">
                    <div class="icon-box blue me-3"><i class="bi bi-book-half"></i></div>
                    <div>
                        <p class="text-muted small mb-0 fw-bold">Clases inscritas</p>
                        <h4 class="fw-bold mb-0 text-dark"><%= listaMaterias.size() %></h4>
                        <p class="text-muted mb-0" style="font-size: 0.75rem;">Este periodo</p>
                    </div>
                </div>
            </div>
            <div class="col-md-4">
                <div class="card p-3 border-0 shadow-sm rounded-4 bg-white d-flex flex-row align-items-center">
                    <div class="icon-box green me-3"><i class="bi bi-calendar-week"></i></div>
                    <div>
                        <p class="text-muted small mb-0 fw-bold">Horario semanal</p>
                        <h4 class="fw-bold mb-0 text-dark"><%= listaMaterias.size() * 5 %></h4>
                        <p class="text-muted mb-0" style="font-size: 0.75rem;">Horas de clases</p>
                    </div>
                </div>
            </div>
            <div class="col-md-4">
                <div class="card p-3 border-0 shadow-sm rounded-4 bg-white d-flex flex-row align-items-center">
                    <div class="icon-box purple me-3"><i class="bi bi-person-workspace"></i></div>
                    <div>
                        <p class="text-muted small mb-0 fw-bold">Profesores</p>
                        <h4 class="fw-bold mb-0 text-dark"><%= listaMaterias.size() %></h4>
                        <p class="text-muted mb-0" style="font-size: 0.75rem;">Este periodo</p>
                    </div>
                </div>
            </div>
        </div>

        <div class="card-custom">
            <h5 class="fw-bold mb-4">Horario y asignaturas</h5>

            <%
                if (listaMaterias.isEmpty()) {
            %>
                <div class="text-center py-4 text-muted">
                    No hay materias registradas en la base de datos para este periodo.
                </div>
            <%
                } else {
                    String[] coloresClase = {"#0d47a1", "#10b981", "#8b5cf6", "#e53e3e", "#d69e2e"};
                    String[] iconosClase = {"bi-calculator", "bi-globe-americas", "bi-translate", "bi-flask", "bi-palette"};
                    int idx = 0;
                    
                    for (Materia m : listaMaterias) {
                        String colorActual = coloresClase[idx % coloresClase.length];
                        String iconoActual = iconosClase[idx % iconosClase.length];
                        
                        // Formateo visual simulado para complementar los datos reales
                        String horarioSimulado = (idx % 2 == 0) ? "Lunes, Miércoles, Viernes • 08:00 - 09:30" : "Martes, Jueves • 10:00 - 11:00";
                        String aulaSimulada = "Aula: " + (200 + m.getId_materia());
            %>
                <div class="class-card d-flex align-items-center justify-content-between">
                    <div class="d-flex align-items-center">
                        <div class="subject-icon shadow-sm" style="background-color: <%= colorActual %>;"><i class="bi <%= iconoActual %>"></i></div>
                        <div>
                            <h5 class="fw-bold mb-1 text-dark"><%= m.getNombre_materia() %></h5>
                            <p class="mb-0 text-muted small"><%= m.getNombre_maestro() %> • <span class="badge bg-light text-dark border"><%= aulaSimulada %></span></p>
                        </div>
                    </div>
                    <div class="text-start px-3" style="min-width: 280px;">
                        <p class="mb-0 small fw-bold text-muted"><i class="bi bi-clock me-1"></i> Horario de grupo</p>
                        <p class="mb-0 small text-dark fw-semibold"><%= horarioSimulado %></p>
                    </div>
                    <div>
                        <a href="#" class="btn-outline-custom">Ver detalles <i class="bi bi-chevron-right ms-1"></i></a>
                    </div>
                </div>
            <%
                        idx++;
                    }
                }
            %>
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
</body>
</html>