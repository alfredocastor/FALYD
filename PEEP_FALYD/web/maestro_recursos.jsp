<%@page import="com.falyd.modelo.Recurso"%>
<%@page import="com.falyd.dao.RecursoDAO"%>
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
    <title>Recursos - Panel del Maestro</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <style>
        :root { --blue-falyd: #0b3b60; --red-falyd: #d32f2f; --bg-light: #f4f7fe; --text-main: #2b3674; --border-color: #e2e8f0; }
        body { background-color: var(--bg-light); font-family: 'Segoe UI', sans-serif; color: var(--text-main); }
        .sidebar { width: 260px; height: 100vh; position: fixed; background: white; z-index: 100; border-bottom-right-radius: 50px; }
        .nav-link { color: #8f9bba; padding: 12px 25px; font-weight: 600; margin: 4px 15px; border-radius: 10px; text-decoration: none; display: block; }
        .nav-link:hover, .nav-link.active { background-color: #e3f2fd; color: var(--blue-falyd); }
        .nav-link.text-danger { color: var(--red-falyd) !important; }
        .main-content { margin-left: 260px; padding: 30px 40px; }
        .card-custom { background: white; border-radius: 20px; padding: 25px; box-shadow: 0 4px 15px rgba(0,0,0,0.02); border: none; }
        .table thead th { border-bottom: 2px solid var(--border-color); color: #8f9bba; font-weight: 600; font-size: 0.8rem; padding-bottom: 15px; text-transform: uppercase; }
        .table tbody td { vertical-align: middle; padding: 15px 10px; border-bottom: 1px solid #f1f5f9; color: var(--text-main); font-size: 0.9rem; }
        .type-badge { font-size: 0.75rem; font-weight: 700; padding: 4px 10px; border-radius: 6px; border: 1px solid; }
        .file-icon { font-size: 1.5rem; width: 40px; height: 40px; display: flex; justify-content: center; align-items: center; border-radius: 10px; color: white; margin-right: 12px; }
        .file-pdf { background-color: #ef4444; }
        .file-doc { background-color: #3b82f6; }
        .file-video { background-color: #8b5cf6; }
        .file-link { background-color: #f59e0b; }
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
            <a class="nav-link active" href="maestro_recursos.jsp"><i class="bi bi-book"></i> Recursos</a>
            <div class="mt-auto mb-4">
<a class="nav-link text-danger" href="#" data-bs-toggle="modal" data-bs-target="#modalCerrarSesion"><i class="bi bi-box-arrow-right"></i> Cerrar sesión</a>            </div>
        </nav>
    </div>

    <div class="main-content">
        <div class="d-flex justify-content-between align-items-center mb-5">
            <div>
                <h4 class="fw-bold mb-0" style="color: var(--blue-falyd);">Sistema Web Escolar</h4>
                <p class="text-muted small mb-0">Panel del Maestro</p>
            </div>
            <div class="d-flex align-items-center bg-white p-2 rounded-pill shadow-sm">
                <div class="dropdown">
                    <button class="btn btn-link text-muted p-0 me-3 position-relative" data-bs-toggle="dropdown" aria-expanded="false">
                        <i class="bi bi-bell-fill fs-5"></i>
                        <span class="position-absolute top-0 start-100 translate-middle p-1 bg-danger border border-light rounded-circle"></span>
                    </button>
                    <ul class="dropdown-menu dropdown-menu-end shadow border-0" style="width: 320px; border-radius: 15px; margin-top: 15px;">
                        <li><h6 class="dropdown-header fw-bold text-dark fs-6 border-bottom pb-2">Notificaciones</h6></li>
                        <li><a class="dropdown-item py-3 border-bottom small text-wrap" href="maestro_calificaciones.jsp"><i class="bi bi-info-circle-fill text-primary me-2"></i>Recuerda calificar las tareas.</a></li>
                        <li><a class="dropdown-item py-3 small text-wrap" href="maestro_calendario.jsp"><i class="bi bi-calendar-event-fill text-warning me-2"></i>Revisa tus próximos eventos en la agenda.</a></li>
                    </ul>
                </div>
                <img src="https://ui-avatars.com/api/?name=<%= user.getNombre() %>&background=e3f2fd&color=0b3b60" class="rounded-circle me-2" width="40">
                <div class="me-3 lh-sm">
                    <p class="mb-0 fw-bold small"><%= user.getNombre() %></p>
                    <p class="mb-0 text-muted" style="font-size: 0.75rem;">Maestro</p>
                </div>
            </div>
        </div>

        <div class="d-flex justify-content-between align-items-end mb-4">
            <div>
                <h1 class="fw-bold mb-1">Recursos</h1>
                <p class="text-muted mb-0">Administra y comparte materiales y recursos educativos con tus alumnos.</p>
            </div>
            <a href="maestro_subir_recurso.jsp" class="btn btn-primary text-decoration-none fw-bold p-3" style="background-color: var(--blue-falyd); border-radius: 10px;">
                <i class="bi bi-plus-lg me-2"></i>Subir recurso
            </a>
        </div>

        <div class="row g-3 mb-4">
            <div class="col-md-5">
                <div class="input-group">
                    <span class="input-group-text bg-white border-end-0 text-muted rounded-start-3"><i class="bi bi-search"></i></span>
                    <input type="text" class="form-control border-start-0 rounded-end-3 bg-white" placeholder="Buscar recurso por nombre...">
                </div>
            </div>
        </div>

        <%
            RecursoDAO rDAO = new RecursoDAO();
            List<Recurso> lista = rDAO.listarRecursosPorMaestro(user.getId_usuario());
            
            int total = lista.size();
            int pdfs = 0, docs = 0, vids = 0, links = 0;
            for(Recurso r : lista) {
                if("PDF".equals(r.getTipo_recurso())) pdfs++;
                else if("Documento".equals(r.getTipo_recurso())) docs++;
                else if("Video".equals(r.getTipo_recurso())) vids++;
                else links++;
            }
        %>

        <div class="row g-4 mb-4">
            <div class="col-md-12">
                <div class="row g-3">
                    <div class="col-md-3"><div class="card p-3 border-0 shadow-sm"><h6>Total</h6><h3><%= total %></h3></div></div>
                    <div class="col-md-3"><div class="card p-3 border-0 shadow-sm"><h6>PDFs</h6><h3><%= pdfs %></h3></div></div>
                    <div class="col-md-3"><div class="card p-3 border-0 shadow-sm"><h6>Documentos</h6><h3><%= docs %></h3></div></div>
                    <div class="col-md-3"><div class="card p-3 border-0 shadow-sm"><h6>Videos / Links</h6><h3><%= vids + links %></h3></div></div>
                </div>
            </div>
        </div>

        <div class="row g-4">
            <div class="col-md-8">
                <div class="card-custom">
                    <h5 class="fw-bold mb-4">Materiales Disponibles</h5>
                    <div class="table-responsive">
                        <table class="table table-borderless align-middle">
                            <thead>
                                <tr>
                                    <th>Nombre</th>
                                    <th>Materia</th>
                                    <th>Tipo</th>
                                    <th>Fecha</th>
                                    <th class="text-center">Enlace</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% if(lista.isEmpty()) { %>
                                    <tr><td colspan="5" class="text-center py-4 text-muted">No has subido ningún material académico aún.</td></tr>
                                <% } else { 
                                    for(Recurso r : lista) { 
                                        String claseIcono = "file-pdf"; String icon = "bi-file-earmark-pdf";
                                        if("Documento".equals(r.getTipo_recurso())) { claseIcono = "file-doc"; icon = "bi-file-earmark-word"; }
                                        else if("Video".equals(r.getTipo_recurso())) { claseIcono = "file-video"; icon = "bi-play-circle"; }
                                        else if("Enlace".equals(r.getTipo_recurso())) { claseIcono = "file-link"; icon = "bi-link-45deg"; }
                                %>
                                    <tr>
                                        <td>
                                            <div class="d-flex align-items-center">
                                                <div class="file-icon <%= claseIcono %> shadow-sm"><i class="bi <%= icon %>"></i></div>
                                                <div>
                                                    <h6 class="fw-bold mb-0 text-dark small"><%= r.getTitulo() %></h6>
                                                    <p class="text-muted mb-0 small"><%= (r.getDescripcion() != null) ? r.getDescripcion() : "" %></p>
                                                </div>
                                            </div>
                                        </td>
                                        <td><span class="text-primary fw-bold"><%= r.getNombre_materia() %></span></td>
                                        <td><span class="type-badge"><%= r.getTipo_recurso() %></span></td>
                                        <td><%= r.getFecha_publicacion() %></td>
                                        <td class="text-center">
                                            <a href="<%= r.getUrl_recurso() %>" target="_blank" class="btn btn-sm btn-light border"><i class="bi bi-box-arrow-up-right"></i> Abrir</a>
                                        </td>
                                    </tr>
                                <% } } %>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>

            <div class="col-md-4">
                <div class="card-custom text-center">
                    <h6 class="fw-bold mb-4 text-start">Distribución de Almacenamiento</h6>
                    <div style="position: relative; height: 160px; width: 100%; display: flex; justify-content: center; align-items: center;">
                        <canvas id="graficaAlmacenamiento"></canvas>
                    </div>
                    <p class="text-muted small mt-4">Calculado proporcionalmente según los tipos de archivos subidos al servidor.</p>
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
        // Gráfica de Dona
        const ctxAlmacenamiento = document.getElementById('graficaAlmacenamiento').getContext('2d');
        new Chart(ctxAlmacenamiento, {
            type: 'doughnut',
            data: {
                labels: ['PDFs', 'Docs', 'Videos', 'Enlaces'],
                datasets: [{
                    data: [<%= pdfs %>, <%= docs %>, <%= vids %>, <%= links %>],
                    backgroundColor: ['#ef4444', '#3b82f6', '#8b5cf6', '#f59e0b'],
                    borderWidth: 0,
                    cutout: '75%'
                }]
            },
            options: { responsive: true, maintainAspectRatio: false, plugins: { legend: { display: false } } }
        });

        // Buscador Dinámico de la Tabla
        document.addEventListener("DOMContentLoaded", function() {
            const searchInput = document.querySelector('input[type="text"][placeholder*="Buscar"]');
            
            if(searchInput) {
                searchInput.addEventListener('input', function(e) {
                    const termino = e.target.value.toLowerCase();
                    const filasTabla = document.querySelectorAll('table tbody tr');
                    
                    filasTabla.forEach(fila => {
                        const textoFila = fila.innerText.toLowerCase();
                        fila.style.display = textoFila.includes(termino) ? '' : 'none';
                    });
                });
            }
        });
    </script>
</body>
</html>