<%@page import="com.falyd.modelo.Usuario"%>
<%@page import="com.falyd.modelo.Alumno"%>
<%@page import="com.falyd.dao.AlumnoDAO"%>
<%@page import="com.falyd.modelo.Tarea"%>
<%@page import="com.falyd.dao.TareaDAO"%>
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

    // 1. Datos del alumno
    AlumnoDAO aDAO = new AlumnoDAO();
    Alumno miPerfil = aDAO.obtenerAlumnoPorUsuario(user.getId_usuario());
    String nombreGrupo = (miPerfil != null && miPerfil.getGrupo() != null) ? miPerfil.getGrupo() : "Sin grupo";

    // 2. Lógica de la Campanita de notificaciones (Tareas pendientes reales)
    TareaDAO tDAO = new TareaDAO();
List<Tarea> misTareas = tDAO.listarTareasPendientesPorAlumno(miPerfil.getId_alumno());
LocalDate hoy = LocalDate.now();
    List<Tarea> tareasPendientes = new ArrayList<>();
    for (Tarea t : misTareas) {
        if (t.getFecha_entrega() != null && !t.getFecha_entrega().isEmpty()) {
            if (ChronoUnit.DAYS.between(hoy, LocalDate.parse(t.getFecha_entrega())) >= 0) {
                tareasPendientes.add(t);
            }
        }
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Centro de Ayuda - Panel del Alumno</title>
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
        
        /* Cajas de accesos superiores */
        .help-icon-box { width: 60px; height: 60px; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-size: 1.8rem; margin: 0 auto 15px auto; }
        .help-card { text-align: center; border: 1px solid var(--border-color); border-radius: 20px; padding: 25px 15px; background: white; transition: 0.2s; height: 100%; }
        .help-card:hover { transform: translateY(-3px); box-shadow: 0 10px 20px rgba(0,0,0,0.03); border-color: #cbd5e1; }
        .btn-help-link { color: var(--blue-falyd); font-weight: 600; border: 1px solid var(--border-color); border-radius: 10px; font-size: 0.85rem; padding: 6px 20px; text-decoration: none; display: inline-block; background: white; transition: 0.2s; }
        .btn-help-link:hover { background-color: #f8fafc; border-color: #cbd5e1; }

        /* Accordion FAQ */
        .accordion-button { font-weight: 600; color: var(--text-main); background-color: transparent !important; box-shadow: none !important; padding: 18px 0; }
        .accordion-button:not(.collapsed) { color: var(--blue-falyd); }
        .accordion-item { border: none; border-bottom: 1px solid var(--border-color); background-color: transparent; }
        .accordion-body { padding: 0 0 18px 0; color: #64748b; font-size: 0.9rem; line-height: 1.5; }

        /* Banner inferior */
        .faq-banner { background-color: #fafcff; border-radius: 20px; padding: 25px; display: flex; align-items: center; justify-content: space-between; border: 1px solid #e3f2fd; margin-top: 30px; }
        .icon-box-headset { width: 45px; height: 45px; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-size: 1.3rem; background-color: #e3f2fd; color: var(--blue-falyd); }
        
        /* Lista lateral derecha */
        .support-item { display: flex; align-items: center; padding: 15px 0; border-bottom: 1px solid #f1f5f9; text-decoration: none; color: inherit; }
        .support-item:last-child { border-bottom: none; }
        .support-item:hover .support-title { color: var(--blue-falyd); }
        .support-icon { width: 40px; height: 40px; border-radius: 10px; display: flex; justify-content: center; align-items: center; font-size: 1.2rem; margin-right: 15px; }
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
            <a class="nav-link" href="alumno_recursos.jsp"><i class="bi bi-folder2-open"></i> Recursos</a>
            <a class="nav-link" href="alumno_calificaciones.jsp"><i class="bi bi-bar-chart-fill"></i> Calificaciones</a>
            <a class="nav-link" href="alumno_mensajes.jsp"><i class="bi bi-chat-dots"></i> Mensajes</a>
            <a class="nav-link active" href="alumno_ayuda.jsp"><i class="bi bi-question-circle"></i> Ayuda</a>
            <div class="mt-auto mb-4">
<a class="nav-link text-danger" href="#" data-bs-toggle="modal" data-bs-target="#modalCerrarSesion"><i class="bi bi-box-arrow-right"></i> Cerrar sesión</a>            </div>
            </div>
        </nav>
    </div>

    <div class="main-content">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <h4 class="fw-bold mb-0" style="color: var(--blue-falyd);">Sistema Web Escolar</h4>
                <p class="text-muted small mb-0">Panel del Alumno</p>
            </div>
            <div class="d-flex align-items-center bg-white p-2 rounded-pill shadow-sm border">
                <div class="dropdown">
                    <button class="btn btn-link text-muted p-0 me-3 position-relative" data-bs-toggle="dropdown">
                        <i class="bi bi-bell-fill fs-5"></i>
                        <% if(!tareasPendientes.isEmpty()) { %>
                            <span class="position-absolute top-0 start-100 translate-middle badge rounded-pill bg-danger border border-light" style="font-size: 0.65rem; padding: 4px 6px;">
                                <%= tareasPendientes.size() %>
                            </span>
                        <% } %>
                    </button>
                    <ul class="dropdown-menu dropdown-menu-end shadow border-0" style="width: 320px; border-radius: 15px; margin-top: 15px;">
                        <li><h6 class="dropdown-header fw-bold text-dark fs-6 border-bottom pb-2">Notificaciones</h6></li>
                        <li><a class="dropdown-item py-3 small text-wrap text-muted" href="alumno_tareas.jsp"><i class="bi bi-journal-text me-2 text-primary"></i>Tienes <%= tareasPendientes.size() %> tareas pendientes.</a></li>
                    </ul>
                </div>
                <img src="https://ui-avatars.com/api/?name=<%= user.getNombre() %>&background=e3f2fd&color=0b3b60" class="rounded-circle me-2" width="40">
                <div class="me-2 lh-sm">
                    <p class="mb-0 fw-bold small"><%= user.getNombre() %></p>
                </div>
            </div>
        </div>

        <div class="mb-4">
            <h1 class="fw-bold mb-1">Centro de ayuda</h1>
            <p class="text-muted mb-0">Estamos aquí para ayudarte. Encuentra respuestas y soluciones rápidas.</p>
        </div>

        <div class="mb-5">
            <div class="input-group input-group-lg shadow-sm" style="border-radius: 15px; overflow: hidden;">
                <span class="input-group-text bg-white border-end-0 text-muted ps-4"><i class="bi bi-search"></i></span>
                <input type="text" class="form-control border-start-0 py-3 text-muted" placeholder="¿En qué podemos ayudarte?" style="font-size: 1.05rem;">
            </div>
        </div>

        <div class="row g-4 mb-5">
            <div class="col-md-3">
                <div class="help-card shadow-sm">
                    <div class="help-icon-box" style="background-color: #e3f2fd; color: #1e88e5;"><i class="bi bi-book"></i></div>
                    <h6 class="fw-bold text-dark mb-2">Guías de uso</h6>
                    <p class="text-muted small mb-4">Aprende a usar el sistema paso a paso con nuestras guías y tutoriales.</p>
                    <a href="#" class="btn-help-link">Ver guías <i class="bi bi-chevron-right small ms-1"></i></a>
                </div>
            </div>
            <div class="col-md-3">
                <div class="help-card shadow-sm">
                    <div class="help-icon-box" style="background-color: #e8f5e9; color: #43a047;"><i class="bi bi-question-circle"></i></div>
                    <h6 class="fw-bold text-dark mb-2">Preguntas frecuentes</h6>
                    <p class="text-muted small mb-4">Encuentra respuestas a las preguntas más comunes sobre el sistema.</p>
                    <a href="#" class="btn-help-link" style="color: #43a047;">Ver FAQs <i class="bi bi-chevron-right small ms-1"></i></a>
                </div>
            </div>
            <div class="col-md-3">
                <div class="help-card shadow-sm">
                    <div class="help-icon-box" style="background-color: #f3e5f5; color: #8e24aa;"><i class="bi bi-play-circle"></i></div>
                    <h6 class="fw-bold text-dark mb-2">Videos tutoriales</h6>
                    <p class="text-muted small mb-4">Videos cortos que te ayudarán a resolver tus dudas fácilmente.</p>
                    <a href="#" class="btn-help-link" style="color: #8e24aa;">Ver videos <i class="bi bi-chevron-right small ms-1"></i></a>
                </div>
            </div>
            <div class="col-md-3">
                <div class="help-card shadow-sm">
                    <div class="help-icon-box" style="background-color: #fff8e1; color: #fdd835;"><i class="bi bi-lightbulb"></i></div>
                    <h6 class="fw-bold text-dark mb-2">Consejos útiles</h6>
                    <p class="text-muted small mb-4">Recomendaciones para aprovechar al máximo todas las funciones.</p>
                    <a href="#" class="btn-help-link" style="color: #d69e2e;">Ver consejos <i class="bi bi-chevron-right small ms-1"></i></a>
                </div>
            </div>
        </div>

        <div class="row g-4">
            <div class="col-md-8">
                <div class="card-custom">
                    <div class="d-flex justify-content-between align-items-center mb-4 border-bottom pb-2">
                        <h5 class="fw-bold mb-0">Preguntas frecuentes</h5>
                        <a href="#" class="text-decoration-none fw-bold small" style="color: var(--blue-falyd);">Ver todas</a>
                    </div>

                    <div class="accordion" id="accordionFAQAlumno">
                        <div class="accordion-item">
                            <h2 class="accordion-header">
                                <button class="accordion-button" type="button" data-bs-toggle="collapse" data-bs-target="#faq1">
                                    ¿Cómo puedo ver mi tareas asignadas?
                                </button>
                            </h2>
                            <div id="faq1" class="accordion-collapse collapse show" data-bs-parent="#accordionFAQAlumno">
                                <div class="accordion-body">
                                    Ve al menú Tareas. Ahí encontrarás todas las tareas pendientes, entregadas y próximas ordenadas por su fecha límite de entrega y prioridad.
                                </div>
                            </div>
                        </div>

                        <div class="accordion-item">
                            <h2 class="accordion-header">
                                <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#faq2">
                                    ¿Cómo puedo consultar mis calificaciones?
                                </button>
                            </h2>
                            <div id="faq2" class="accordion-collapse collapse" data-bs-parent="#accordionFAQAlumno">
                                <div class="accordion-body">
                                    Puedes ver tus calificaciones en el menú Calificaciones. También puedes filtrarlas por periodo y ver tu promedio general calculado automáticamente.
                                </div>
                            </div>
                        </div>

                        <div class="accordion-item">
                            <h2 class="accordion-header">
                                <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#faq3">
                                    ¿Cómo descargo un recurso o archivo?
                                </button>
                            </h2>
                            <div id="faq3" class="accordion-collapse collapse" data-bs-parent="#accordionFAQAlumno">
                                <div class="accordion-body">
                                    En el menú Recursos, selecciona el archivo de apoyo o guía de estudio que deseas y presiona el botón Descargar para guardarlo en tu dispositivo.
                                </div>
                            </div>
                        </div>

                        <div class="accordion-item">
                            <h2 class="accordion-header">
                                <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#faq4">
                                    ¿Cómo envío un mensaje a mi profesor?
                                </button>
                            </h2>
                            <div id="faq4" class="accordion-collapse collapse" data-bs-parent="#accordionFAQAlumno">
                                <div class="accordion-body">
                                    En el menú Mensajes, selecciona la conversación del docente en tu barra izquierda, escribe en la caja inferior de texto y presiona el botón de enviar.
                                </div>
                            </div>
                        </div>

                        <div class="accordion-item">
                            <h2 class="accordion-header">
                                <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#faq5">
                                    ¿Qué hago si no puedo ingresar al sistema?
                                </button>
                            </h2>
                            <div id="faq5" class="accordion-collapse collapse" data-bs-parent="#accordionFAQAlumno">
                                <div class="accordion-body">
                                    Verifica tu conexión a internet e intenta nuevamente. Si olvidaste tus credenciales o el problema persiste, contacta directamente a soporte técnico.
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="faq-banner">
                        <div class="d-flex align-items-center">
                            <div class="icon-box-headset me-3"><i class="bi bi-headset"></i></div>
                            <div>
                                <h6 class="fw-bold mb-1 text-dark">¿No encuentras lo que buscas?</h6>
                                <p class="text-muted small mb-0">Enviónos tu consulta y te ayudaremos a encontrar la solución.</p>
                            </div>
                        </div>
                        <button class="btn btn-primary fw-bold px-4" style="background-color: var(--blue-falyd); border-radius: 10px;"><i class="bi bi-envelope me-2"></i> Enviar consulta</button>
                    </div>
                </div>
            </div>

            <div class="col-md-4">
                <div class="card-custom mb-4">
                    <h5 class="fw-bold mb-3">¿Necesitas más ayuda?</h5>
                    <p class="text-muted small mb-4">Nuestro equipo está listo para asistirte.</p>

                    <a href="#" class="support-item">
                        <div class="support-icon" style="background-color: #e3f2fd; color: #1e88e5;"><i class="bi bi-envelope"></i></div>
                        <div>
                            <h6 class="fw-bold mb-1 support-title text-dark" style="font-size: 0.9rem;">Enviar solicitud</h6>
                            <p class="text-muted mb-0" style="font-size: 0.75rem;">Cuéntanos tu problema y te responderemos pronto.</p>
                        </div>
                        <i class="bi bi-chevron-right ms-auto text-muted small"></i>
                    </a>

                    <a href="#" class="support-item">
                        <div class="support-icon" style="background-color: #e8f5e9; color: #43a047;"><i class="bi bi-chat-dots"></i></div>
                        <div>
                            <h6 class="fw-bold mb-1 support-title text-dark" style="font-size: 0.9rem;">Chat en línea</h6>
                            <p class="text-muted mb-0" style="font-size: 0.75rem;">Habla con un asesor en tiempo real.</p>
                        </div>
                        <i class="bi bi-chevron-right ms-auto text-muted small"></i>
                    </a>

                    <a href="#" class="support-item">
                        <div class="support-icon" style="background-color: #f3e5f5; color: #8e24aa;"><i class="bi bi-shield-slash"></i></div>
                        <div>
                            <h6 class="fw-bold mb-1 support-title text-dark" style="font-size: 0.9rem;">Soporte técnico</h6>
                            <p class="text-muted mb-0" style="font-size: 0.75rem;">Reporta fallas o problemas técnicos.</p>
                        </div>
                        <i class="bi bi-chevron-right ms-auto text-muted small"></i>
                    </a>
                </div>

                <div class="card-custom mb-4">
                    <h6 class="fw-bold mb-3">Estado del sistema</h6>
                    <div class="d-flex align-items-center bg-light p-3 rounded-3 border">
                        <div class="me-3 fs-2 text-success"><i class="bi bi-check-circle-fill"></i></div>
                        <div>
                            <p class="fw-bold mb-1 small text-dark">Todos los sistemas funcionan correctamente.</p>
                            <p class="text-muted mb-0" style="font-size: 0.7rem;">Última actualización: 24 de abril de 2024, 09:45 AM</p>
                        </div>
                    </div>
                </div>

                <div class="card-custom">
                    <h6 class="fw-bold mb-3">Horario de atención</h6>
                    <div class="d-flex align-items-start">
                        <i class="bi bi-clock text-muted me-3 fs-5"></i>
                        <div>
                            <p class="mb-2 small"><strong class="text-dark">Lunes a Viernes</strong><br><span class="text-muted">7:00 AM - 6:00 PM</span></p>
                            <p class="mb-0 small"><strong class="text-dark">Sábados</strong><br><span class="text-muted">8:00 AM - 12:00 PM</span></p>
                        </div>
                    </div>
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
</body>
</html>