const express = require('express');
const path = require('path');
const cors = require('cors');
const db = require('./db'); // tu conexión MySQL

const app = express();
const port = 3000;

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.static(path.join(__dirname, 'public')));

// Página principal
app.get('/', (req, res) => {
  res.sendFile(path.join(__dirname, 'public', 'inicio-sesion.html'));
});

// 🔐 ENDPOINT LOGIN
app.post('/api/login', (req, res) => {
  const { usuario, contrasena } = req.body;

  if (!usuario || !contrasena) {
    return res.status(400).json({
      success: false,
      message: 'Usuario y contraseña son requeridos'
    });
  }

  const query = 'SELECT * FROM empleados WHERE usuario = ? AND contrasena = ?';
  db.query(query, [usuario, contrasena], (err, results) => {
    if (err) {
      console.error('❌ Error en consulta MySQL:', err);
      return res.status(500).json({
        success: false,
        message: 'Error del servidor en la base de datos'
      });
    }

    if (results.length > 0) {
      const empleado = results[0];
      res.json({
        success: true,
        message: 'Login exitoso',
        token: 'authenticated',
        empleado: {
          rut: empleado.rut,
          nombre: empleado.nombre,
          cargo: empleado.cargo,
          region: empleado.region,
          horario: empleado.horario,
          disponibilidad: empleado.disponibilidad,
          usuario: empleado.usuario
        }
      });
    } else {
      res.status(401).json({
        success: false,
        message: 'Usuario o contraseña incorrectos'
      });
    }
  });
});

// 🩺 ENDPOINT ESTADO SERVIDOR
app.get('/api/status', (req, res) => {
  db.query('SELECT 1 as test', (err) => {
    if (err) {
      return res.json({
        status: 'Servidor funcionando pero BD con error',
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

// 👥 ENDPOINT EMPLEADOS
app.get('/api/empleados', (req, res) => {
  db.query('SELECT * FROM empleados', (err, results) => {
    if (err) {
      console.error('Error al obtener empleados:', err);
      return res.status(500).json({ error: 'Error en la consulta' });
    }
    res.json(results);
  });
});

// Inicia servidor
app.listen(port, () => {
  console.log(`Servidor iniciado en http://localhost:${port}`);
});
