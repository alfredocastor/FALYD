<%@page import="com.falyd.dao.GrupoDAO"%>
<%@page import="com.falyd.modelo.Usuario"%>
<%@page import="com.falyd.dao.MaestroDAO"%>
<%@page import="com.falyd.dao.AlumnoDAO"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    HttpSession sesion = request.getSession();
    Usuario user = (Usuario) sesion.getAttribute("usuarioActual");

    // Seguridad: Solo el ADMIN puede ver esta pantalla
    if (user == null || !user.getTipo_usuario().equals("ADMIN")) {
        response.sendRedirect("login.jsp");
        return;
    }

    // Calculamos las estadísticas reales usando tus DAOs
    MaestroDAO mDAO = new MaestroDAO();
    int totalMaestros = mDAO.listarMaestros().size();

    AlumnoDAO aDAO = new AlumnoDAO();
    int totalAlumnos = aDAO.listarAlumnos().size();

    GrupoDAO gDAO = new GrupoDAO();
    int totalGrupos = gDAO.listarGrupos().size();
%>
<!DOCTYPE html>
<html lang="es">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Dashboard - Admin FALYD</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
        <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css">
        <style>
            :root {
                --blue-falyd: #0b3b60;
                --red-falyd: #d32f2f;
            }
            body {
                background-color: #f0f2f5;
                font-family: 'Segoe UI', sans-serif;
            }
            .sidebar {
                width: 250px;
                height: 100vh;
                position: fixed;
                background: #1a1d20;
                color: white;
                border-right: 1px solid #333;
            }
            .nav-link {
                color: #adb5bd;
                padding: 12px 20px;
                font-weight: 500;
            }
            .nav-link:hover, .nav-link.active {
                background-color: #343a40;
                color: white;
                border-left: 4px solid var(--red-falyd);
            }
            .main-content {
                margin-left: 250px;
                padding: 30px;
            }
            .header-panel {
                background: white;
                padding: 15px 30px;
                border-bottom: 1px solid #ddd;
                margin-left: 250px;
            }
            .card-custom {
                border-radius: 15px;
                border: none;
                box-shadow: 0 4px 10px rgba(0,0,0,0.05);
            }
        </style>
    </head>
    <body>

        <div class="sidebar d-flex flex-column">
            <div class="p-4 bg-dark text-center">
                <h4 class="text-white fw-bold">Admin FALYD</h4>
            </div>
            <nav class="nav flex-column mt-3">
                <a class="nav-link active" href="panel_admin.jsp"><i class="bi bi-speedometer2 me-2"></i> Dashboard</a>

                <p class="text-uppercase text-muted small ms-3 mt-3 mb-1">Gestión de Usuarios</p>
                <a class="nav-link" href="admin_maestros.jsp"><i class="bi bi-person-badge me-2"></i> Maestros</a>
                <a class="nav-link" href="admin_alumnos.jsp"><i class="bi bi-people me-2"></i> Alumnos</a>
                <a class="nav-link" href="#"><i class="bi bi-person-workspace me-2"></i> Secretaría</a>

                <p class="text-uppercase text-muted small ms-3 mt-3 mb-1">Sistema</p>
                <a class="nav-link" href="admin_grupos.jsp"><i class="bi bi-journal-bookmark me-2"></i> Materias y Grupos</a>
                <a class="nav-link" href="#"><i class="bi bi-gear me-2"></i> Configuración</a>
                <hr class="border-secondary">
                <a class="nav-link text-danger" href="LogoutServlet"><i class="bi bi-box-arrow-left me-2"></i> Cerrar sesión</a>
            </nav>
        </div>

        <div class="header-panel d-flex justify-content-between align-items-center">
            <h5 class="mb-0 fw-bold" style="color: var(--blue-falyd);">Control Central del Sistema</h5>
            <div class="d-flex align-items-center">
                <div class="text-end me-3">
                    <p class="mb-0 fw-bold small"><%= user.getNombre()%></p>
                    <p class="mb-0 text-muted small">Administrador</p>
                </div>
                <img src="https://ui-avatars.com/api/?name=<%= user.getNombre()%>&background=d32f2f&color=fff" class="rounded-circle" width="40">
            </div>
        </div>

        <div class="main-content">
            <h2 class="fw-bold mb-4">Vista General del Sistema</h2>

            <div class="row g-4 mb-4">
                <div class="col-md-3">
                    <div class="card card-custom p-4 border-bottom border-primary border-4 text-center h-100">
                        <h6 class="text-muted small text-uppercase fw-bold">Total Alumnos</h6>
                        <h2 class="fw-bold mb-0 text-primary"><%= totalAlumnos%></h2>
                    </div>
                </div>

                <div class="col-md-3">
                    <div class="card card-custom p-4 border-bottom border-success border-4 text-center h-100">
                        <h6 class="text-muted small text-uppercase fw-bold">Plantilla Docente</h6>
                        <h2 class="fw-bold mb-0 text-success"><%= totalMaestros%></h2>
                    </div>
                </div>

                <div class="col-md-3">
                    <div class="card card-custom p-4 border-bottom border-warning border-4 text-center h-100">
                        <h6 class="text-muted small text-uppercase fw-bold">Grupos Activos</h6>
                        <h2 class="fw-bold mb-0 text-warning"><%= totalGrupos%></h2>
                    </div>
                </div>

                <div class="col-md-3">
                    <div class="card card-custom p-4 border-bottom border-danger border-4 text-center h-100">
                        <h6 class="text-muted small text-uppercase fw-bold">Alertas del Sistema</h6>
                        <h2 class="fw-bold mb-0 text-danger">0</h2>
                    </div>
                </div>
            </div>

            <div class="alert alert-primary mt-4 border-0 shadow-sm" role="alert">
                <h5 class="fw-bold"><i class="bi bi-info-circle-fill me-2"></i>Bienvenido al panel de control de PEEP</h5>
                <p class="mb-0">Desde este panel puedes gestionar todas las cuentas de usuario, configurar los grupos oficiales del ciclo escolar y monitorear el estado general de la plataforma.</p>
            </div>
        </div>

        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    </body>
</html>