# Referidos Jav's Corp — instalación

## 1. Supabase (gratis)
1. Crea cuenta en supabase.com > New project (guarda la contraseña de la base de datos).
2. SQL Editor > New query > pega `supabase-setup.sql` > Run. Antes, cambia `CAMBIA-ESTE-CODIGO` por el código que darás a tus empleados.
3. Project Settings > API: copia **Project URL** y **anon public key** y pégalos en `config.js`.
4. Authentication > Providers > Email: desactiva **Confirm email** (así entran sin confirmar correo).
5. Authentication > URL Configuration: en **Site URL** pon la dirección final de tu página (para el correo de "olvidé mi contraseña").

## 2. Netlify
- Sitio nuevo: arrastra la carpeta/ZIP a Netlify.
- Dentro de tu sitio actual: crea la carpeta `referidos`, copia ahí `index.html` y `config.js`, y sube todo el proyecto (quedará en javscorp.netlify.app/referidos). OJO: arrastrar solo este ZIP a tu sitio actual lo reemplaza por completo.

## 3. Tu cuenta de administrador
1. Abre la página, pestaña "Crear cuenta", regístrate con tu correo y el código.
2. En Supabase > SQL Editor ejecuta la línea del paso 6 del archivo SQL (con tu correo).
3. Recarga la página: verás la pestaña "Panel admin" con los referidos de todos.

## 4. Empleados
Dales el link y el código de registro. Cada uno crea su cuenta y solo ve sus referidos.
