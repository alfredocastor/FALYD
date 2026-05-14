<%@page import="com.falyd.modelo.Usuario"%>
<%@page import="com.falyd.modelo.Maestro"%>
<%@page import="com.falyd.dao.MaestroDAO"%>
<%@page import="java.util.List"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    HttpSession sesion = request.getSession();
    Usuario user = (Usuario) sesion.getAttribute("usuarioActual");

    // Seguridad: Solo el ADMIN puede ver esta pantalla
    if (user == null || !user.getTipo_usuario().equals("ADMIN")) {
        response.sendRedirect("login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="es">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Gestión de Maestros - FALYD</title>
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
                <a class="nav-link" href="panel_admin.jsp"><i class="bi bi-speedometer2 me-2"></i> Dashboard</a>
                <p class="text-uppercase text-muted small ms-3 mt-3 mb-1">Gestión de Usuarios</p>
                <a class="nav-link active" href="admin_maestros.jsp"><i class="bi bi-person-badge me-2"></i> Maestros</a>
                <a class="nav-link" href="admin_alumnos.jsp"><i class="bi bi-people me-2"></i> Alumnos</a>
                <a class="nav-link" href="#"><i class="bi bi-person-workspace me-2"></i> Secretaría</a>
                <p class="text-uppercase text-muted small ms-3 mt-3 mb-1">Sistema</p>
                <a class="nav-link" href="#"><i class="bi bi-journal-bookmark me-2"></i> Materias y Grupos</a>
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
            <h2 class="fw-bold mb-4">Gestión de Maestros</h2>

            <div class="card card-custom p-4">
                <div class="d-flex justify-content-between align-items-center mb-4">
                    <h5 class="fw-bold mb-0"><i class="bi bi-person-badge me-2 text-primary"></i>Plantilla Docente</h5>
                    <button class="btn btn-dark" data-bs-toggle="modal" data-bs-target="#modalNuevoMaestro">
                        <i class="bi bi-plus-lg me-2"></i>Nuevo Maestro
                    </button>
                </div>

                <div class="table-responsive">
                    <table class="table table-hover align-middle">
                        <thead class="table-light">
                            <tr>
                                <th>ID Maestro</th>
                                <th>Nombre Completo</th>
                                <th>Correo / Usuario</th>
                                <th>Estado</th>
                                <th>Acciones</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                                MaestroDAO mDAO = new MaestroDAO();
                                List<Maestro> lista = mDAO.listarMaestros();
                                for (Maestro m : lista) {
                            %>
                            <tr>
                                <td><strong><%= m.getId_maestro()%></strong></td>
                                <td>
                                    <div class="d-flex align-items-center">
                                        <img src="https://ui-avatars.com/api/?name=<%= m.getNombre()%>&background=random&color=fff" class="rounded-circle me-2" width="32">
                                        <%= m.getNombre()%>
                                    </div>
                                </td>
                                <td>
                                    <span class="text-muted small"><i class="bi bi-envelope me-1"></i><%= m.getCorreo()%></span>
                                </td>
                                <td><span class="badge bg-success-subtle text-success border border-success-subtle">Activo</span></td>
                                <td>
                                    <button class="btn btn-sm btn-outline-primary" data-bs-toggle="modal" data-bs-target="#modalEditarMaestro<%= m.getId_maestro()%>" title="Editar">
                                        <i class="bi bi-pencil"></i>
                                    </button>
                                    <button class="btn btn-sm btn-outline-danger ms-1" data-bs-toggle="modal" data-bs-target="#modalEliminarMaestro<%= m.getId_maestro()%>" title="Eliminar">
                                        <i class="bi bi-trash"></i>
                                    </button>
                                </td>
                            </tr>

                        <div class="modal fade" id="modalEditarMaestro<%= m.getId_maestro()%>" tabindex="-1" aria-hidden="true">
                            <div class="modal-dialog modal-dialog-centered">
                                <div class="modal-content border-0 shadow">
                                    <div class="modal-header bg-primary text-white">
                                        <h5 class="modal-title fw-bold"><i class="bi bi-pencil-square me-2"></i>Editar Maestro</h5>
                                        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                                    </div>
                                    <form action="MaestroServlet" method="POST">
                                        <div class="modal-body p-4">
                                            <input type="hidden" name="accion" value="editar">
                                            <input type="hidden" name="id_usuario" value="<%= m.getId_usuario()%>">
                                            <input type="hidden" name="id_maestro" value="<%= m.getId_maestro()%>">

                                            <div class="mb-3">
                                                <label class="form-label fw-bold small text-muted">Nombre Completo</label>
                                                <input type="text" class="form-control" name="nombre" value="<%= m.getNombre()%>" required>
                                            </div>

                                            <div class="mb-3">
                                                <label class="form-label fw-bold small text-muted">Correo Electrónico (Login)</label>
                                                <input type="email" class="form-control" name="correo" value="<%= m.getCorreo()%>" required>
                                            </div>

                                            <div class="mb-3">
                                                <label class="form-label fw-bold small text-muted">Nueva Contraseña</label>
                                                <input type="password" class="form-control" name="password" placeholder="Dejar en blanco para no cambiarla">
                                            </div>
                                        </div>
                                        <div class="modal-footer bg-light border-0">
                                            <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancelar</button>
                                            <button type="submit" class="btn btn-primary px-4">Actualizar Cambios</button>
                                        </div>
                                    </form>
                                </div>
                            </div>
                        </div>

                        <div class="modal fade" id="modalEliminarMaestro<%= m.getId_maestro()%>" tabindex="-1" aria-hidden="true">
                            <div class="modal-dialog modal-dialog-centered">
                                <div class="modal-content border-0 shadow">
                                    <div class="modal-header bg-danger text-white">
                                        <h5 class="modal-title fw-bold"><i class="bi bi-exclamation-triangle-fill me-2"></i>Eliminar Maestro</h5>
                                        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                                    </div>
                                    <form action="MaestroServlet" method="POST">
                                        <div class="modal-body p-4 text-center">
                                            <input type="hidden" name="accion" value="eliminar">
                                            <input type="hidden" name="id_usuario" value="<%= m.getId_usuario()%>">
                                            <input type="hidden" name="id_maestro" value="<%= m.getId_maestro()%>">

                                            <i class="bi bi-person-x text-danger mb-3" style="font-size: 3rem;"></i>
                                            <p class="fs-5 mb-1">¿Estás seguro de que deseas dar de baja al maestro <br><strong><%= m.getNombre()%></strong>?</p>
                                            <p class="text-muted small">Esta acción eliminará su acceso al sistema y lo desvinculará de sus materias.</p>
                                        </div>
                                        <div class="modal-footer bg-light border-0 justify-content-center">
                                            <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancelar</button>
                                            <button type="submit" class="btn btn-danger px-4">Sí, dar de baja</button>
                                        </div>
                                    </form>
                                </div>
                            </div>
                        </div>

                        <% }%>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>

        <div class="modal fade" id="modalNuevoMaestro" tabindex="-1" aria-hidden="true">
            <div class="modal-dialog modal-dialog-centered">
                <div class="modal-content border-0 shadow">
                    <div class="modal-header bg-dark text-white">
                        <h5 class="modal-title fw-bold"><i class="bi bi-person-plus-fill me-2"></i>Registrar Maestro</h5>
                        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <form action="MaestroServlet" method="POST">
                        <div class="modal-body p-4">
                            <input type="hidden" name="accion" value="agregar">

                            <div class="mb-3">
                                <label class="form-label fw-bold small text-muted">Nombre Completo</label>
                                <input type="text" class="form-control" name="nombre" placeholder="Nombre y Apellidos" required>
                            </div>

                            <div class="mb-3">
                                <label class="form-label fw-bold small text-muted">Correo Electrónico (Login)</label>
                                <input type="email" class="form-control" name="correo" placeholder="ejemplo@peep.com" required>
                            </div>

                            <div class="mb-3">
                                <label class="form-label fw-bold small text-muted">Contraseña Provisional</label>
                                <input type="password" class="form-control" name="password" placeholder="Mínimo 6 caracteres" required>
                            </div>
                        </div>
                        <div class="modal-footer bg-light border-0">
                            <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancelar</button>
                            <button type="submit" class="btn btn-dark px-4">Guardar Maestro</button>
                        </div>
                    </form>
                </div>
            </div>
        </div>

        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    </body>
</html>