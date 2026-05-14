<%@page import="com.falyd.modelo.Usuario"%>
<%@page import="com.falyd.modelo.Grupo"%>
<%@page import="com.falyd.dao.GrupoDAO"%>
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
        <title>Gestión de Grupos - FALYD</title>
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
                <a class="nav-link" href="admin_maestros.jsp"><i class="bi bi-person-badge me-2"></i> Maestros</a>
                <a class="nav-link" href="#"><i class="bi bi-people me-2"></i> Alumnos</a>
                <a class="nav-link" href="#"><i class="bi bi-person-workspace me-2"></i> Secretaría</a>
                
                <p class="text-uppercase text-muted small ms-3 mt-3 mb-1">Sistema</p>
                <a class="nav-link active" href="admin_grupos.jsp"><i class="bi bi-journal-bookmark me-2"></i> Materias y Grupos</a>
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
            <h2 class="fw-bold mb-4">Gestión de Grupos y Ciclos</h2>

            <div class="card card-custom p-4">
                <div class="d-flex justify-content-between align-items-center mb-4">
                    <h5 class="fw-bold mb-0"><i class="bi bi-diagram-3 me-2 text-warning"></i>Grupos Oficiales de la Escuela</h5>
                    <button class="btn btn-dark" data-bs-toggle="modal" data-bs-target="#modalNuevoGrupo">
                        <i class="bi bi-plus-lg me-2"></i>Crear Grupo
                    </button>
                </div>

                <div class="table-responsive">
                    <table class="table table-hover align-middle text-center">
                        <thead class="table-light">
                            <tr>
                                <th>ID Grupo</th>
                                <th>Nombre del Grupo</th>
                                <th>Estado</th>
                                <th>Acciones</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                                GrupoDAO gDAO = new GrupoDAO();
                                List<Grupo> listaGrupos = gDAO.listarGrupos();
                                for (Grupo g : listaGrupos) {
                            %>
                            <tr>
                                <td><strong><%= g.getId_grupo() %></strong></td>
                                <td><span class="fs-5 fw-semibold"><%= g.getNombre_grupo() %></span></td>
                                <td><span class="badge bg-success-subtle text-success border border-success-subtle">Activo</span></td>
                                <td>
                                    <button class="btn btn-sm btn-outline-primary" data-bs-toggle="modal" data-bs-target="#modalEditarGrupo<%= g.getId_grupo() %>" title="Editar">
                                        <i class="bi bi-pencil"></i>
                                    </button>
                                    <button class="btn btn-sm btn-outline-danger ms-1" data-bs-toggle="modal" data-bs-target="#modalEliminarGrupo<%= g.getId_grupo() %>" title="Eliminar">
                                        <i class="bi bi-trash"></i>
                                    </button>
                                </td>
                            </tr>

                            <div class="modal fade" id="modalEditarGrupo<%= g.getId_grupo() %>" tabindex="-1" aria-hidden="true">
                                <div class="modal-dialog modal-dialog-centered modal-sm">
                                    <div class="modal-content border-0 shadow">
                                        <div class="modal-header bg-primary text-white">
                                            <h5 class="modal-title fw-bold"><i class="bi bi-pencil-square me-2"></i>Editar Grupo</h5>
                                            <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                                        </div>
                                        <form action="GrupoServlet" method="POST">
                                            <div class="modal-body p-4">
                                                <input type="hidden" name="accion" value="editar">
                                                <input type="hidden" name="id_grupo" value="<%= g.getId_grupo() %>">
                                                
                                                <div class="mb-3">
                                                    <label class="form-label fw-bold small text-muted">Nombre del Grupo</label>
                                                    <input type="text" class="form-control text-center fs-5 fw-bold" name="nombre_grupo" value="<%= g.getNombre_grupo() %>" required>
                                                </div>
                                            </div>
                                            <div class="modal-footer bg-light border-0 justify-content-center">
                                                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancelar</button>
                                                <button type="submit" class="btn btn-primary px-4">Actualizar</button>
                                            </div>
                                        </form>
                                    </div>
                                </div>
                            </div>

                            <div class="modal fade" id="modalEliminarGrupo<%= g.getId_grupo() %>" tabindex="-1" aria-hidden="true">
                                <div class="modal-dialog modal-dialog-centered">
                                    <div class="modal-content border-0 shadow">
                                        <div class="modal-header bg-danger text-white">
                                            <h5 class="modal-title fw-bold"><i class="bi bi-exclamation-triangle-fill me-2"></i>Eliminar Grupo</h5>
                                            <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                                        </div>
                                        <form action="GrupoServlet" method="POST">
                                            <div class="modal-body p-4 text-center">
                                                <input type="hidden" name="accion" value="eliminar">
                                                <input type="hidden" name="id_grupo" value="<%= g.getId_grupo() %>">
                                                
                                                <i class="bi bi-diagram-3 text-danger mb-3" style="font-size: 3rem;"></i>
                                                <p class="fs-5 mb-1">¿Borrar el grupo <strong class="fs-4"><%= g.getNombre_grupo() %></strong>?</p>
                                                <p class="text-muted small text-danger fw-bold mt-2">¡Cuidado! Los alumnos asignados a este grupo quedarán sin salón.</p>
                                            </div>
                                            <div class="modal-footer bg-light border-0 justify-content-center">
                                                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancelar</button>
                                                <button type="submit" class="btn btn-danger px-4">Sí, borrar</button>
                                            </div>
                                        </form>
                                    </div>
                                </div>
                            </div>

                            <% } %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>

        <div class="modal fade" id="modalNuevoGrupo" tabindex="-1" aria-hidden="true">
            <div class="modal-dialog modal-dialog-centered modal-sm">
                <div class="modal-content border-0 shadow">
                    <div class="modal-header bg-dark text-white">
                        <h5 class="modal-title fw-bold"><i class="bi bi-plus-circle me-2"></i>Nuevo Grupo</h5>
                        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <form action="GrupoServlet" method="POST">
                        <div class="modal-body p-4 text-center">
                            <input type="hidden" name="accion" value="agregar">

                            <div class="mb-3">
                                <label class="form-label fw-bold small text-muted">Nombre del Grupo</label>
                                <input type="text" class="form-control text-center fs-5 fw-bold" name="nombre_grupo" placeholder="Ej. 1º A" required>
                                <div class="form-text mt-2">Usa el formato oficial de la escuela.</div>
                            </div>
                        </div>
                        <div class="modal-footer bg-light border-0 justify-content-center">
                            <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancelar</button>
                            <button type="submit" class="btn btn-dark px-4">Crear Grupo</button>
                        </div>
                    </form>
                </div>
            </div>
        </div>

        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    </body>
</html>