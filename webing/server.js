const express = require('express');
const path = require('path');
const app = express();
const port = 3000;
//Importa la conexión
const db = require('./db');

//Permite recibir JSON en peticiones POST
app.use(express.json());

app.use(express.static(path.join(__dirname, 'public')));//carpeta hija

app.get('/', (req, res) => {
res.sendFile(path.join(__dirname, 'public', 'inicio-sesion.html'));
});

//Ejemplo de ruta que lee datos desde MySQL
app.get('/api/empleados', (req, res) => {
  db.query('SELECT * FROM empleados', (err, results) => {
    if (err) {
      console.error('Error al consultar MySQL:', err);
      res.status(500).send('Error en la consulta');
      return;
    }
    res.json(results);
  });
});

app.get('/api/status', (req, res) => {
  res.json({ base_datos: 'Conectado' }); 
});

// Ruta de login
app.post('/api/login', (req, res) => {
  const { usuario, contrasena } = req.body;

  if (!usuario || !contrasena) {
    return res.status(400).json({ success: false, message: 'Faltan datos de usuario o contraseña' });
  }

  // Consulta MySQL
  const sql = 'SELECT * FROM empleados WHERE usuario = ? AND contrasena = ?';
  db.query(sql, [usuario, contrasena], (err, results) => {
    if (err) {
      console.error('❌ Error en consulta MySQL:', err);
      return res.status(500).json({ success: false, message: 'Error en el servidor' });
    }

    if (results.length === 0) {
      // No se encontró el usuario
      return res.status(401).json({ success: false, message: 'Usuario o contraseña incorrectos' });
    }

    // Si llega aquí, hay coincidencia
    const empleado = results[0];
    res.json({
      success: true,
      message: 'Inicio de sesión exitoso',
      empleado: {
        id: empleado.id,
        nombre: empleado.nombre,
        cargo: empleado.cargo,
        usuario: empleado.usuario
      }
    });
  });
});




//Inicia el servidor
app.listen(port, () => {
console.log(`Servidor iniciado en http://localhost:${port}`);
});

const cors = require('cors');
app.use(cors());