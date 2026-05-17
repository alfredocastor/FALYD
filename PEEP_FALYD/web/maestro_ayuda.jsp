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
    <title>Centro de Ayuda - Panel del Maestro</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css">
    <style>
        :root { --blue-falyd: #0b3b60; --red-falyd: #d32f2f; --bg-light: #f4f7fe; --text-main: #2b3674; --border-color: #e2e8f0; }
        body { background-color: var(--bg-light); font-family: 'Segoe UI', sans-serif; color: var(--text-main); }
        
        .sidebar { width: 260px; height: 100vh; position: fixed; background: white; z-index: 100; border-bottom-right-radius: 50px; }
        .nav-link { color: #8f9bba; padding: 12px 25px; font-weight: 600; margin: 4px 15px; border-radius: 10px; transition: all 0.3s; text-decoration: none; display: block; }
        .nav-link i { font-size: 1.2rem; margin-right: 12px; }
        .nav-link:hover, .nav-link.active { background-color: #e3f2fd; color: var(--blue-falyd); }
        .nav-link.text-danger { color: var(--red-falyd) !important; }
        
        .main-content { margin-left: 260px; padding: 30px 40px; }
        .card-custom { background: white; border-radius: 20px; padding: 25px; box-shadow: 0 4px 15px rgba(0,0,0,0.02); border: none; }
        
        /* Cajas de iconos superiores */
        .help-icon-box { width: 60px; height: 60px; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-size: 1.8rem; margin: 0 auto 15px auto; }
        .help-card { text-align: center; border: 1px solid var(--border-color); border-radius: 20px; padding: 25px 15px; background: white; transition: 0.2s; height: 100%; }
        .help-card:hover { transform: translateY(-3px); box-shadow: 0 10px 20px rgba(0,0,0,0.03); border-color: #cbd5e1; }
        .btn-help-link { color: var(--blue-falyd); font-weight: 600; text-decoration: none; font-size: 0.85rem; padding-top: 10px; display: inline-block; }
        .btn-help-link:hover { color: #082d4a; }

        /* Accordion FAQ */
        .accordion-button { font-weight: 600; color: var(--text-main); background-color: transparent !important; box-shadow: none !important; padding: 15px 0; }
        .accordion-button:not(.collapsed) { color: var(--blue-falyd); }
        .accordion-item { border: none; border-bottom: 1px solid var(--border-color); background-color: transparent; }
        .accordion-body { padding: 0 0 15px 0; color: #64748b; font-size: 0.9rem; }

        /* Banner inferior FAQ */
        .faq-banner { background-color: #f8fafc; border-radius: 15px; padding: 20px; display: flex; align-items: center; justify-content: space-between; border: 1px solid var(--border-color); margin-top: 30px; }
        
        /* Lista lateral derecha */
        .support-item { display: flex; align-items: center; padding: 15px 0; border-bottom: 1px solid #f1f5f9; text-decoration: none; color: inherit; }
        .support-item:last-child { border-bottom: none; }
        .support-item:hover .support-title { color: var(--blue-falyd); }
        .support-icon { width: 40px; height: 40px; border-radius: 10px; display: flex; justify-content: center; align-items: center; font-size: 1.2rem; margin-right: 15px; }
    </style>
</head>
<body>

    <div class="sidebar d-flex flex-column">
        <div class="p-4 text-center"><img src="img/Logo.png" width="120"></div>
        <nav class="nav flex-column mt-2 flex-grow-1">
            <a class="nav-link" href="panel_maestro.jsp"><i class="bi bi-house-door-fill"></i> Inicio</a>
            <a class="nav-link" href="maestro_tareas.jsp"><i class="bi bi-check2-square"></i> Tareas</a>
            <a class="nav-link" href="maestro_calendario.jsp"><i class="bi bi-calendar3"></i> Calendario</a>
            <a class="nav-link" href="maestro_alumnos.jsp"><i class="bi bi-people-fill"></i> Alumnos</a>
            <a class="nav-link" href="maestro_calificaciones.jsp"><i class="bi bi-clipboard-data"></i> Calificaciones</a>
            <a class="nav-link" href="maestro_recursos.jsp"><i class="bi bi-book"></i> Recursos</a>
            <a class="nav-link" href="maestro_mensajes.jsp"><i class="bi bi-chat-dots"></i> Mensajes</a>
            <div class="mt-auto mb-4">
                <a class="nav-link active" href="maestro_ayuda.jsp"><i class="bi bi-question-circle"></i> Ayuda</a>
                <a class="nav-link text-danger" href="LogoutServlet"><i class="bi bi-box-arrow-right"></i> Cerrar sesión</a>
            </div>
        </nav>
    </div>

    <div class="main-content">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <h4 class="fw-bold mb-0" style="color: var(--blue-falyd);">Sistema Web Escolar</h4>
                <p class="text-muted small mb-0">Panel del Maestro</p>
            </div>
            <div class="d-flex align-items-center bg-white p-2 rounded-pill shadow-sm">
                <div class="dropdown">
                    <button class="btn btn-link text-muted p-0 me-3 position-relative" data-bs-toggle="dropdown">
                        <i class="bi bi-bell-fill fs-5"></i>
                        <span class="position-absolute top-0 start-100 translate-middle p-1 bg-danger border border-light rounded-circle"></span>
                    </button>
                    <ul class="dropdown-menu dropdown-menu-end shadow border-0" style="width: 320px; border-radius: 15px; margin-top: 15px;">
                        <li><h6 class="dropdown-header fw-bold text-dark fs-6 border-bottom pb-2">Notificaciones</h6></li>
                        <li><a class="dropdown-item py-3 border-bottom small text-wrap" href="maestro_calificaciones.jsp"><i class="bi bi-info-circle-fill text-primary me-2"></i>Recuerda calificar las tareas.</a></li>
                    </ul>
                </div>
                <img src="https://ui-avatars.com/api/?name=<%= user.getNombre() %>&background=e3f2fd&color=0b3b60" class="rounded-circle me-2" width="40">
                <div class="me-3 lh-sm">
                    <p class="mb-0 fw-bold small"><%= user.getNombre() %></p>
                    <p class="mb-0 text-muted" style="font-size: 0.75rem;">Maestro</p>
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
                <input type="text" class="form-control border-start-0 py-3" placeholder="¿En qué podemos ayudarte?">
            </div>
        </div>

        <div class="row g-4 mb-5">
            <div class="col-md-3">
                <div class="help-card">
                    <div class="help-icon-box" style="background-color: #e3f2fd; color: #1e88e5;"><i class="bi bi-book"></i></div>
                    <h6 class="fw-bold">Guías de uso</h6>
                    <p class="text-muted small mb-3">Aprende a usar el sistema paso a paso con nuestras guías.</p>
                    <a href="#" class="btn-help-link border-top w-100 pt-3">Ver guías <i class="bi bi-chevron-right ms-1"></i></a>
                </div>
            </div>
            <div class="col-md-3">
                <div class="help-card">
                    <div class="help-icon-box" style="background-color: #e8f5e9; color: #43a047;"><i class="bi bi-question-circle"></i></div>
                    <h6 class="fw-bold">Preguntas frecuentes</h6>
                    <p class="text-muted small mb-3">Encuentra respuestas a las dudas más comunes sobre el sistema.</p>
                    <a href="#" class="btn-help-link border-top w-100 pt-3" style="color: #43a047;">Ver FAQs <i class="bi bi-chevron-right ms-1"></i></a>
                </div>
            </div>
            <div class="col-md-3">
                <div class="help-card">
                    <div class="help-icon-box" style="background-color: #f3e5f5; color: #8e24aa;"><i class="bi bi-play-circle"></i></div>
                    <h6 class="fw-bold">Videos tutoriales</h6>
                    <p class="text-muted small mb-3">Videos cortos que te ayudarán a dominar todas las funciones.</p>
                    <a href="#" class="btn-help-link border-top w-100 pt-3" style="color: #8e24aa;">Ver videos <i class="bi bi-chevron-right ms-1"></i></a>
                </div>
            </div>
            <div class="col-md-3">
                <div class="help-card">
                    <div class="help-icon-box" style="background-color: #fff8e1; color: #fdd835;"><i class="bi bi-lightbulb"></i></div>
                    <h6 class="fw-bold">Consejos útiles</h6>
                    <p class="text-muted small mb-3">Recomendaciones para aprovechar al máximo tu panel de profesor.</p>
                    <a href="#" class="btn-help-link border-top w-100 pt-3" style="color: #d69e2e;">Ver consejos <i class="bi bi-chevron-right ms-1"></i></a>
                </div>
            </div>
        </div>

        <div class="row g-4">
            <div class="col-md-8">
                <div class="card-custom h-100">
                    <div class="d-flex justify-content-between align-items-center mb-4">
                        <h5 class="fw-bold mb-0">Preguntas frecuentes</h5>
                        <a href="#" class="text-decoration-none fw-bold small" style="color: var(--blue-falyd);">Ver todas</a>
                    </div>

                    <div class="accordion" id="accordionFAQ">
                        <div class="accordion-item">
                            <h2 class="accordion-header">
                                <button class="accordion-button" type="button" data-bs-toggle="collapse" data-bs-target="#faq1">
                                    ¿Cómo puedo crear y asignar una nueva tarea?
                                </button>
                            </h2>
                            <div id="faq1" class="accordion-collapse collapse show" data-bs-parent="#accordionFAQ">
                                <div class="accordion-body">
                                    Ve al menú "Tareas" en la barra lateral izquierda y haz clic en el botón azul "Crear nueva tarea". Completa el formulario con el título, descripción, fecha de entrega y selecciona la materia correspondiente.
                                </div>
                            </div>
                        </div>

                        <div class="accordion-item">
                            <h2 class="accordion-header">
                                <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#faq2">
                                    ¿Cómo registro y descargo las calificaciones?
                                </button>
                            </h2>
                            <div id="faq2" class="accordion-collapse collapse" data-bs-parent="#accordionFAQ">
                                <div class="accordion-body">
                                    En la sección "Calificaciones", selecciona una tarea y un alumno para asentar su nota. Para descargar el reporte general de una materia, elige la materia en el menú desplegable y presiona "Exportar PDF".
                                </div>
                            </div>
                        </div>

                        <div class="accordion-item">
                            <h2 class="accordion-header">
                                <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#faq3">
                                    ¿Cómo agendo un evento en el calendario?
                                </button>
                            </h2>
                            <div id="faq3" class="accordion-collapse collapse" data-bs-parent="#accordionFAQ">
                                <div class="accordion-body">
                                    Accede a "Calendario" y presiona "Crear evento". Podrás seleccionar la fecha, la materia vinculada, y asignarle un color específico (por ejemplo, rojo para evaluaciones o azul para clases).
                                </div>
                            </div>
                        </div>

                        <div class="accordion-item">
                            <h2 class="accordion-header">
                                <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#faq4">
                                    ¿Qué hago si un alumno no aparece en mi lista?
                                </button>
                            </h2>
                            <div id="faq4" class="accordion-collapse collapse" data-bs-parent="#accordionFAQ">
                                <div class="accordion-body">
                                    La asignación de alumnos a grupos es administrada por Control Escolar. Si un estudiante falta en tu padrón, por favor levanta un ticket en el área de Soporte Técnico o comunícate con la Secretaría Académica.
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="faq-banner">
                        <div class="d-flex align-items-center">
                            <div class="icon-box me-3" style="background-color: white; color: var(--blue-falyd); border: 1px solid var(--border-color);"><i class="bi bi-headset"></i></div>
                            <div>
                                <h6 class="fw-bold mb-1">¿No encuentras lo que buscas?</h6>
                                <p class="text-muted small mb-0">Envíanos tu consulta y te ayudaremos a encontrar la solución.</p>
                            </div>
                        </div>
                        <button class="btn btn-primary fw-bold px-4" style="background-color: var(--blue-falyd); border-radius: 10px;">Enviar consulta</button>
                    </div>
                </div>
            </div>

            <div class="col-md-4">
                <div class="card-custom mb-4">
                    <h5 class="fw-bold mb-3">¿Necesitas más ayuda?</h5>
                    <p class="text-muted small mb-4">Nuestro equipo técnico está listo para asistirte.</p>

                    <a href="#" class="support-item">
                        <div class="support-icon" style="background-color: #e3f2fd; color: #1e88e5;"><i class="bi bi-envelope"></i></div>
                        <div>
                            <h6 class="fw-bold mb-1 support-title text-dark" style="font-size: 0.9rem;">Enviar solicitud</h6>
                            <p class="text-muted mb-0" style="font-size: 0.75rem;">Cuéntanos tu problema por correo.</p>
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
                        <div class="support-icon" style="background-color: #f3e5f5; color: #8e24aa;"><i class="bi bi-headset"></i></div>
                        <div>
                            <h6 class="fw-bold mb-1 support-title text-dark" style="font-size: 0.9rem;">Soporte técnico</h6>
                            <p class="text-muted mb-0" style="font-size: 0.75rem;">Reporta fallas graves del sistema.</p>
                        </div>
                        <i class="bi bi-chevron-right ms-auto text-muted small"></i>
                    </a>
                </div>

                <div class="card-custom mb-4">
                    <h6 class="fw-bold mb-3">Estado del sistema</h6>
                    <div class="d-flex align-items-center bg-light p-3 rounded-3">
                        <div class="me-3 fs-2 text-success"><i class="bi bi-check-circle-fill"></i></div>
                        <div>
                            <p class="fw-bold mb-1 small text-dark">Todos los sistemas operativos</p>
                            <p class="text-muted mb-0" style="font-size: 0.7rem;">Última actualización: Hoy, 07:00 AM</p>
                        </div>
                    </div>
                </div>

                <div class="card-custom">
                    <h6 class="fw-bold mb-3">Horario de atención</h6>
                    <div class="d-flex align-items-start">
                        <i class="bi bi-clock text-muted me-3 fs-5"></i>
                        <div>
                            <p class="mb-1 small"><strong class="text-dark">Lunes a Viernes</strong><br><span class="text-muted">7:00 AM - 6:00 PM</span></p>
                            <p class="mb-0 small"><strong class="text-dark">Sábados</strong><br><span class="text-muted">8:00 AM - 1:00 PM</span></p>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>