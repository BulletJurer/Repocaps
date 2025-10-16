// ------------------- IMPORTACIONES ------------------- //
const express = require('express');
const path = require('path');
const cors = require('cors');
const db = require('./db'); // conexión a la base de datos
const app = express();
const port = 3000;

// ------------------- MIDDLEWARE ------------------- //
// Permite recibir JSON en las peticiones POST
app.use(express.json());

// Habilita CORS para que api.js pueda hacer fetch
app.use(cors());

// Carpeta de archivos estáticos (html, css, js)
app.use(express.static(path.join(__dirname, 'public')));

// ------------------- RUTAS PÚBLICAS ------------------- //
// Página principal (login)
app.get('/', (req, res) => {
  res.sendFile(path.join(__dirname, 'public', 'inicio-sesion.html'));
});

// ------------------- ENDPOINT DE LOGIN ------------------- //
app.post('/api/login', (req, res) => {
  const { usuario, contrasena } = req.body;

  // Validación simple
  if (!usuario || !contrasena) {
    return res.status(400).json({
      success: false,
      message: 'Usuario y contraseña son requeridos'
    });
  }

  // Consulta a la base de datos
  const query = 'SELECT * FROM empleados WHERE usuario = ? AND contrasena = ?';
  db.query(query, [usuario, contrasena], (err, results) => {
    if (err) {
      console.error('❌ Error en consulta MySQL:', err);
      return res.status(500).json({ success: false, message: 'Error del servidor' });
    }

    if (results.length > 0) {
      const empleado = results[0];
      // Login exitoso, devolvemos la info completa
      res.json({
        success: true,
        message: 'Inicio de sesión exitoso',
        empleado: {
          id: empleado.id,
          rut: empleado.rut,
          nombre: empleado.nombre,
          cargo: empleado.cargo,
          region: empleado.region,
          horario: empleado.horario,
          disponibilidad: empleado.disponibilidad,
          usuario: empleado.usuario
        },
        token: "authenticated" // token simple para frontend
      });
    } else {
      res.status(401).json({ success: false, message: 'Usuario o contraseña incorrectos' });
    }
  });
});

// ------------------- ENDPOINT DE ESTADO DEL SERVIDOR ------------------- //
app.get('/api/status', (req, res) => {
  db.query('SELECT 1 AS test', (err) => {
    if (err) {
      return res.json({
        status: 'Servidor activo pero BD con error',
        error: err.message,
        timestamp: new Date().toISOString()
      });
    }
    res.json({
      status: 'Servidor y BD funcionando correctamente',
      timestamp: new Date().toISOString(),
      base_datos: 'prueba_pepsi'
    });
  });
});

// ------------------- ENDPOINT DE EMPLEADOS ------------------- //
app.get('/api/empleados', (req, res) => {
  const query = 'SELECT rut, nombre, cargo, region, usuario, horario, disponibilidad FROM empleados';
  db.query(query, (err, results) => {
    if (err) {
      console.error('❌ Error obteniendo empleados:', err);
      return res.status(500).json({ error: 'Error en la consulta' });
    }
    res.json(results);
  });
});

// ------------------- INICIAR SERVIDOR ------------------- //
app.listen(port, () => {
  console.log(`Servidor iniciado en http://localhost:${port}`);
  console.log(`📋 Endpoints disponibles:`);
  console.log(`   POST http://localhost:${port}/api/login`);
  console.log(`   GET  http://localhost:${port}/api/status`);
  console.log(`   GET  http://localhost:${port}/api/empleados`);
});
