<%@page import="com.falyd.modelo.Alumno"%>
<%@page import="com.falyd.dao.AlumnoDAO"%>
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
        <title>Alumnos - Panel del Maestro</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
        <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css">
        <style>
            :root {
                --blue-falyd: #0b3b60;
                --red-falyd: #d32f2f;
                --bg-light: #f4f7fe;
                --text-main: #2b3674;
                --border-color: #e2e8f0;
            }
            body {
                background-color: var(--bg-light);
                font-family: 'Segoe UI', sans-serif;
                color: var(--text-main);
            }

            /* Sidebar */
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
                padding-bottom: 60px;
            }

            /* Tabla de Alumnos UI Moderno */
            .table-container {
                background: white;
                border-radius: 20px;
                padding: 25px;
                box-shadow: 0 4px 15px rgba(0,0,0,0.02);
            }
            .table {
                margin-bottom: 0;
            }
            .table thead th {
                border-bottom: 2px solid var(--border-color);
                color: #8f9bba;
                font-weight: 600;
                font-size: 0.85rem;
                padding-bottom: 15px;
                text-transform: uppercase;
                letter-spacing: 0.5px;
            }
            .table tbody td {
                vertical-align: middle;
                padding: 15px 10px;
                border-bottom: 1px solid #f1f5f9;
                color: var(--text-main);
                font-weight: 500;
                font-size: 0.95rem;
            }
            .table tbody tr:hover {
                background-color: #f8fafc;
            }

            .avatar-img {
                width: 45px;
                height: 45px;
                border-radius: 50%;
                object-fit: cover;
            }
            .status-badge {
                padding: 5px 12px;
                border-radius: 20px;
                font-size: 0.75rem;
                font-weight: 700;
            }
            .status-active {
                background-color: #def7ec;
                color: #03543f;
            }

            .btn-icon {
                background: #f8fafc;
                border: 1px solid var(--border-color);
                color: var(--blue-falyd);
                width: 35px;
                height: 35px;
                border-radius: 8px;
                display: inline-flex;
                align-items: center;
                justify-content: center;
                transition: 0.2s;
                text-decoration: none;
            }
            .btn-icon:hover {
                background: #e3f2fd;
                border-color: #bbdefb;
                color: var(--blue-falyd);
            }
        </style>
    </head>
    <body>

        <div class="sidebar d-flex flex-column">
            <div class="p-4 text-center">
                <img src="img/Logo.png" alt="FALYD Logo" style="width: 120px; margin-bottom: 5px;">
            </div>
            <nav class="nav flex-column mt-2 flex-grow-1">
                <a class="nav-link" href="panel_maestro.jsp"><i class="bi bi-house-door-fill"></i> Inicio</a>
                <a class="nav-link" href="maestro_tareas.jsp"><i class="bi bi-check2-square"></i> Tareas</a>
                <a class="nav-link" href="maestro_calendario.jsp"><i class="bi bi-calendar3"></i> Calendario</a>
                <a class="nav-link active" href="maestro_alumnos.jsp"><i class="bi bi-people-fill"></i> Alumnos</a>
                <a class="nav-link" href="maestro_calificaciones.jsp"><i class="bi bi-clipboard-data"></i> Calificaciones</a>
                <a class="nav-link" href="maestro_recursos.jsp"><i class="bi bi-book"></i> Recursos</a>
                <div class="mt-auto mb-4">
                    <a class="nav-link text-danger" href="LogoutServlet"><i class="bi bi-box-arrow-right"></i> Cerrar sesión</a>
                </div>
            </nav>
        </div>

        <div class="main-content">

            <div class="d-flex justify-content-between align-items-center mb-5">
                <div>
                    <h4 class="fw-bold mb-0" style="color: var(--blue-falyd);">Sistema Web Escolar</h4>
                    <h5 class="fw-bold mb-0" style="color: var(--red-falyd);">Luis Moya</h5>
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
                    <img src="https://ui-avatars.com/api/?name=<%= user.getNombre()%>&background=e3f2fd&color=0b3b60" class="rounded-circle me-2" width="40">
                    <div class="me-3 lh-sm">
                        <p class="mb-0 fw-bold small"><%= user.getNombre()%></p>
                        <p class="mb-0 text-muted" style="font-size: 0.75rem;">Maestro</p>
                    </div>
                </div>
            </div>

            <div class="mb-4">
                <h1 class="fw-bold mb-1">Alumnos</h1>
                <p class="text-muted mb-0">Consulta la información de los alumnos inscritos en tus grupos.</p>
            </div>

            <div class="row g-3 mb-4">
                <div class="col-md-5">
                    <div class="input-group">
                        <span class="input-group-text bg-white border-end-0 text-muted rounded-start-3"><i class="bi bi-search"></i></span>
                        <input type="text" class="form-control border-start-0 rounded-end-3 bg-white" placeholder="Buscar alumno por nombre o matrícula...">
                    </div>
                </div>
                <div class="col-md-3">
                    <button class="btn btn-white border w-100 rounded-3 text-muted fw-bold d-flex justify-content-between align-items-center">
                        Todos los grupos <i class="bi bi-chevron-down"></i>
                    </button>
                </div>
                <div class="col-md-2">
                    <button class="btn btn-white border w-100 rounded-3 text-muted fw-bold d-flex justify-content-center align-items-center">
                        <i class="bi bi-funnel me-2"></i> Filtros
                    </button>
                </div>
            </div>

            <div class="table-container">
                <div class="table-responsive">
                    <table class="table table-borderless align-middle">
                        <thead>
                            <tr>
                                <th style="width: 35%;">Alumno</th>
                                <th style="width: 15%;">Grupo</th>
                                <th style="width: 25%;">Correo</th>
                                <th style="width: 15%;">Estado</th>
                                <th style="width: 10%; text-align: center;">Acciones</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                                // Usamos el DAO que ya tienes programado
                                AlumnoDAO dao = new AlumnoDAO();
                                List<Alumno> listaAlumnos = dao.listarAlumnos();

                                if (listaAlumnos.isEmpty()) {
                            %>
                            <tr>
                                <td colspan="5" class="text-center py-4 text-muted">
                                    No hay alumnos registrados en la base de datos.
                                </td>
                            </tr>
                            <%
                            } else {
                                for (Alumno a : listaAlumnos) {
                                    // Obtenemos el grupo (si es nulo ponemos un texto por defecto)
                                    String grupo = (a.getGrupo() != null && !a.getGrupo().isEmpty()) ? a.getGrupo() : "Sin asignar";
                            %>
                            <tr>
                                <td>
                                    <div class="d-flex align-items-center">
                                        <img src="https://ui-avatars.com/api/?name=<%= a.getNombre()%>&background=random&color=fff" class="avatar-img me-3">
                                        <div>
                                            <h6 class="mb-0 fw-bold"><%= a.getNombre()%></h6>
                                            <p class="text-muted small mb-0">Matrícula: <%= String.format("%05d", a.getId_alumno())%></p>
                                        </div>
                                    </div>
                                </td>
                                <td>
                                    <span class="text-muted fw-bold"><%= grupo%></span>
                                </td>
                                <td>
                                    <span class="text-muted"><%= a.getCorreo()%></span>
                                </td>
                                <td>
                                    <span class="status-badge status-active">Activo</span>
                                </td>
                                <td class="text-center">
                                    <a href="#" class="btn-icon" title="Ver detalles">
                                        <i class="bi bi-eye-fill"></i>
                                    </a>
                                </td>
                            </tr>
                            <%
                                    }
                                }
                            %>
                        </tbody>
                    </table>
                </div>

                <div class="d-flex justify-content-between align-items-center mt-4 pt-3 border-top">
                    <p class="text-muted small mb-0">Mostrando datos reales de la base de datos</p>
                </div>
            </div>

        </div>
            <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

        <script>
            // Script universal para dar vida a los buscadores de FALYD
            document.addEventListener("DOMContentLoaded", function () {
                // Buscamos el input de texto (la barra de búsqueda)
                const searchInput = document.querySelector('input[type="text"][placeholder*="Buscar"]');

                if (searchInput) {
                    searchInput.addEventListener('input', function (e) {
                        const termino = e.target.value.toLowerCase();

                        // Buscamos si hay una tabla (como en Alumnos o Recursos)
                        const filasTabla = document.querySelectorAll('table tbody tr');
                        if (filasTabla.length > 0) {
                            filasTabla.forEach(fila => {
                                const textoFila = fila.innerText.toLowerCase();
                                fila.style.display = textoFila.includes(termino) ? '' : 'none';
                            });
                        }

                        // Buscamos si hay tarjetas (como en Tareas)
                        const tarjetas = document.querySelectorAll('.task-card');
                        if (tarjetas.length > 0) {
                            tarjetas.forEach(tarjeta => {
                                const textoTarjeta = tarjeta.innerText.toLowerCase();
                                tarjeta.style.display = textoTarjeta.includes(termino) ? 'flex' : 'none';
                            });
                        }
                    });
                }
            });
    </body>
</html>