<%@page import="com.falyd.modelo.Usuario"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    HttpSession sesion = request.getSession();
    Usuario user = (Usuario) sesion.getAttribute("usuarioActual");

    // Seguridad
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
        <title>Panel del Maestro - FALYD</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
        <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css">
        <style>
            :root {
                --blue-falyd: #0b3b60;
                --red-falyd: #d32f2f;
                --bg-light: #f4f7fe;
                --text-main: #2b3674;
                --text-muted: #a3aed1;
            }
            body {
                background-color: var(--bg-light);
                font-family: 'Segoe UI', sans-serif;
                color: var(--text-main);
            }

            /* Sidebar personalizado */
            .sidebar {
                width: 260px;
                height: 100vh;
                position: fixed;
                background: white;
                border-right: none;
                box-shadow: 2px 0 20px rgba(0,0,0,0.04);
                z-index: 100;
                border-bottom-right-radius: 50px;
            }
            .nav-link {
                color: #8f9bba;
                padding: 12px 25px;
                font-weight: 600;
                margin: 4px 15px;
                border-radius: 10px;
                transition: all 0.3s;
            }
            .nav-link i {
                font-size: 1.2rem;
                margin-right: 12px;
            }
            .nav-link:hover {
                background-color: #f4f7fe;
                color: var(--blue-falyd);
            }
            .nav-link.active {
                background-color: #e3f2fd;
                color: var(--blue-falyd);
            }
            .nav-link.text-danger {
                color: var(--red-falyd) !important;
            }

            .main-content {
                margin-left: 260px;
                padding: 30px 40px;
            }

            /* Tarjetas estilo UI moderno */
            .card-custom {
                border-radius: 20px;
                border: none;
                box-shadow: 0 4px 15px rgba(0,0,0,0.03);
                background: white;
                padding: 20px;
            }
            .welcome-card {
                background: linear-gradient(135deg, #e3f2fd 0%, #bbdefb 100%);
                border-radius: 20px;
                padding: 30px;
                border: none;
            }

            /* Botones y badges */
            .btn-outline-custom {
                border: 1px solid #e2e8f0;
                color: var(--text-main);
                border-radius: 12px;
                font-weight: 600;
            }
            .btn-primary-custom {
                background-color: var(--blue-falyd);
                color: white;
                border-radius: 10px;
                font-weight: 600;
                padding: 6px 16px;
                border: none;
            }
            .icon-box {
                width: 45px;
                height: 45px;
                border-radius: 12px;
                display: flex;
                align-items: center;
                justify-content: center;
                font-size: 1.5rem;
            }
            .icon-box.blue {
                background-color: #e3f2fd;
                color: var(--blue-falyd);
            }
            .icon-box.red {
                background-color: #ffebee;
                color: var(--red-falyd);
            }

            /* Cuadrícula de accesos rápidos */
            .quick-access-btn {
                text-align: center;
                padding: 15px;
                border: 1px solid #e2e8f0;
                border-radius: 16px;
                transition: all 0.2s;
                cursor: pointer;
                text-decoration: none;
                color: var(--text-main);
                display: block;
            }
            .quick-access-btn:hover {
                background-color: #f8fafc;
                border-color: #cbd5e1;
                transform: translateY(-3px);
            }
            .quick-access-btn i {
                font-size: 2rem;
                color: var(--blue-falyd);
                margin-bottom: 10px;
                display: block;
            }
        </style>
    </head>
    <body>

        <div class="sidebar d-flex flex-column">
            <div class="p-4 text-center">
                <img src="img/Logo.png" alt="FALYD Logo" style="width: 120px; margin-bottom: 5px;">
            </div>
            <nav class="nav flex-column mt-2 flex-grow-1">
                <a class="nav-link active" href="#"><i class="bi bi-house-door-fill"></i> Inicio</a>
                <a class="nav-link" href="maestro_tareas.jsp"><i class="bi bi-check2-square"></i> Tareas</a>
                <a class="nav-link" href="maestro_calendario.jsp"><i class="bi bi-calendar3"></i> Calendario</a>
                <a class="nav-link" href="maestro_alumnos.jsp"><i class="bi bi-people-fill"></i> Alumnos</a>
                <a class="nav-link" href="maestro_calificaciones.jsp"><i class="bi bi-clipboard-data"></i> Calificaciones</a>
                <a class="nav-link" href="#"><i class="bi bi-book"></i> Recursos</a>
                <a class="nav-link" href="#"><i class="bi bi-chat-dots"></i> Mensajes</a>

                <div class="mt-auto mb-4">
                    <a class="nav-link" href="#"><i class="bi bi-question-circle"></i> Ayuda</a>
                    <a class="nav-link text-danger" href="LogoutServlet"><i class="bi bi-box-arrow-right"></i> Cerrar sesión</a>
                </div>
            </nav>
        </div>

        <div class="main-content">

            <div class="d-flex justify-content-between align-items-center mb-4">
                <div>
                    <h4 class="fw-bold mb-0" style="color: var(--blue-falyd);">Sistema Web Escolar</h4>
                    <h5 class="fw-bold mb-0" style="color: var(--red-falyd);">Luis Moya</h5>
                    <p class="text-muted small mb-0">Panel del Maestro</p>
                </div>
                <div class="d-flex align-items-center bg-white p-2 rounded-pill shadow-sm">
                    <button class="btn btn-link text-muted p-0 me-3 position-relative">
                        <i class="bi bi-bell-fill fs-5"></i>
                        <span class="position-absolute top-0 start-100 translate-middle p-1 bg-danger border border-light rounded-circle"></span>
                    </button>
                    <img src="https://ui-avatars.com/api/?name=<%= user.getNombre()%>&background=e3f2fd&color=0b3b60" class="rounded-circle me-2" width="40">
                    <div class="me-3 lh-sm">
                        <p class="mb-0 fw-bold small"><%= user.getNombre()%></p>
                        <p class="mb-0 text-muted" style="font-size: 0.75rem;">Maestro</p>
                    </div>
                    <i class="bi bi-chevron-down text-muted me-2"></i>
                </div>
            </div>

            <div class="welcome-card mb-4 d-flex justify-content-between align-items-center">
                <div>
                    <h2 class="fw-bold text-dark mb-2">¡Bienvenido(a), <%= user.getNombre()%>! 👋</h2>
                    <p class="text-muted mb-0">Gestiona tus tareas, alumnos y actividades académicas.</p>
                </div>
                <img src="https://cdn-icons-png.flaticon.com/512/3048/3048122.png" width="100" class="opacity-75">
            </div>

            <div class="row g-4 mb-4">
                <div class="col-md-6">
                    <div class="card-custom h-100">
                        <div class="d-flex justify-content-between align-items-center mb-4">
                            <h5 class="fw-bold mb-0">Agenda de hoy</h5>
                            <button class="btn btn-outline-custom btn-sm"><i class="bi bi-calendar4 me-1"></i> Ver calendario</button>
                        </div>
                        <p class="text-muted small mb-3">Miércoles 24 de abril de 2026</p>

                        <div class="d-flex align-items-center mb-3 p-3 border rounded-4">
                            <div class="icon-box blue me-3"><i class="bi bi-clipboard-check"></i></div>
                            <div>
                                <h6 class="fw-bold mb-1 text-dark">Registrar calificaciones</h6>
                                <p class="mb-0 small text-muted">Matemáticas - 3º A y 3º B <br><span class="text-warning">08:00 - 09:00</span></p>
                            </div>
                        </div>

                        <div class="d-flex align-items-center mb-3 p-3 border rounded-4">
                            <div class="icon-box blue me-3"><i class="bi bi-book"></i></div>
                            <div>
                                <h6 class="fw-bold mb-1 text-dark">Revisar tareas</h6>
                                <p class="mb-0 small text-muted">Historia - 2º A <br><span class="text-danger">11:00 - 12:00</span></p>
                            </div>
                        </div>

                        <div class="d-flex align-items-center p-3 border rounded-4">
                            <div class="icon-box blue me-3"><i class="bi bi-people"></i></div>
                            <div>
                                <h6 class="fw-bold mb-1 text-dark">Atención a alumnos</h6>
                                <p class="mb-0 small text-muted">Tutoría <br><span class="text-danger">14:00 - 15:00</span></p>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="col-md-6">
                    <div class="card-custom h-100">
                        <h5 class="fw-bold mb-4">Accesos rápidos</h5>
                        <div class="row g-3">
                            <div class="col-6">
                                <a href="#" class="quick-access-btn">
                                    <i class="bi bi-file-earmark-plus"></i>
                                    <span class="fw-bold small">Crear tarea</span>
                                </a>
                            </div>
                            <div class="col-6">
                                <a href="#" class="quick-access-btn">
                                    <i class="bi bi-folder-plus"></i>
                                    <span class="fw-bold small">Crear material</span>
                                </a>
                            </div>
                            <div class="col-6">
                                <a href="#" class="quick-access-btn">
                                    <i class="bi bi-people-fill"></i>
                                    <span class="fw-bold small">Ver alumnos</span>
                                </a>
                            </div>
                            <div class="col-6">
                                <a href="#" class="quick-access-btn">
                                    <i class="bi bi-clipboard2-check"></i>
                                    <span class="fw-bold small text-wrap">Registrar<br>calificaciones</span>
                                </a>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <div class="row g-4">
                <div class="col-md-7">
                    <div class="card-custom h-100">
                        <div class="d-flex justify-content-between align-items-center mb-4">
                            <h5 class="fw-bold mb-0">Tareas pendientes</h5>
                            <button class="btn btn-outline-custom btn-sm">Ver todas</button>
                        </div>

                        <div class="d-flex justify-content-between align-items-center border-bottom pb-3 mb-3">
                            <div class="d-flex align-items-center">
                                <div class="icon-box red me-3"><i class="bi bi-clipboard-data"></i></div>
                                <div>
                                    <h6 class="fw-bold mb-1 text-dark">Revisar ejercicios de álgebra</h6>
                                    <p class="mb-0 small text-muted">3º A - Entrega: 26 abr</p>
                                </div>
                            </div>
                            <button class="btn btn-primary-custom">Revisar</button>
                        </div>

                        <div class="d-flex justify-content-between align-items-center">
                            <div class="d-flex align-items-center">
                                <div class="icon-box red me-3"><i class="bi bi-book"></i></div>
                                <div>
                                    <h6 class="fw-bold mb-1 text-dark">Lectura: Revolución Industrial</h6>
                                    <p class="mb-0 small text-muted">2º B - Entrega: 25 abr</p>
                                </div>
                            </div>
                            <button class="btn btn-primary-custom">Revisar</button>
                        </div>
                    </div>
                </div>

                <div class="col-md-5">
                    <div class="card-custom h-100">
                        <div class="d-flex justify-content-between align-items-center mb-4">
                            <h5 class="fw-bold mb-0">Notificaciones</h5>
                            <button class="btn btn-outline-custom btn-sm">Ver todas</button>
                        </div>

                        <div class="d-flex align-items-start mb-3">
                            <div class="icon-box red me-3" style="width: 35px; height: 35px; font-size: 1.2rem;"><i class="bi bi-bell-fill"></i></div>
                            <div>
                                <h6 class="fw-bold mb-0 text-dark small">Tienes 12 tareas pendientes por revisar</h6>
                                <p class="mb-0 text-muted" style="font-size: 0.7rem;">Hace 1 hora</p>
                            </div>
                        </div>

                        <div class="d-flex align-items-start">
                            <div class="icon-box blue me-3" style="width: 35px; height: 35px; font-size: 1.2rem;"><i class="bi bi-info-circle-fill"></i></div>
                            <div>
                                <h6 class="fw-bold mb-0 text-dark small">Se ha publicado un nuevo recurso en Historia</h6>
                                <p class="mb-0 text-muted" style="font-size: 0.7rem;">Hace 3 horas</p>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

        </div>

        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    </body>
</html>