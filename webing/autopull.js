const http = require('http');
const createHandler = require('github-webhook-handler');
const { exec } = require('child_process');

const handler = createHandler({ path: '/webhook', secret: 'mipasswordsegura' });

// Servidor que escucha las notificaciones del webhook
http.createServer((req, res) => {
  handler(req, res, (err) => {
    res.statusCode = 404;
    res.end('No existe esta ruta.');
  });
}).listen(7777, () => {
  console.log('Servidor webhook escuchando en puerto 7777');
});

handler.on('error', err => {
  console.error('Error:', err.message);
});

// Cuando detecte un push en GitHub:
handler.on('push', function (event) {
  const branch = event.payload.ref.split('/').pop(); // obtiene el nombre de la rama
  console.log(`Push detectado en la rama: ${branch}`);

  if (branch === 'appweb') {
    console.log('Actualizando proyecto...');
    exec('git pull origin appweb', (err, stdout, stderr) => {
      if (err) {
        console.error('Error al hacer git pull:', err);
        return;
      }
      console.log(stdout);
    });
  } else {
    console.log('Push en otra rama, ignorado.');
  }
});
