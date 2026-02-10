// lib/widgets/terms_dialog.dart

import 'package:flutter/material.dart';

class TermsDialog extends StatelessWidget {
  const TermsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Términos y Condiciones'),
      content: const SingleChildScrollView(
        child: Text(

                'Bienvenido a **tuc Comercial**. Al usar esta aplicación, aceptas estar sujeto a estos términos.\n\n'
                '**1. Objeto de la Aplicación**\n'
                '"Tuc comercial" es una plataforma destinada a servir como guía comercial, permitiendo a los comercios locales publicar información sobre sus productos y servicios.\n\n'
                '**2. Contenido y Publicaciones**\n'
                'Los comercios son los únicos responsables de la información que publican. Las imágenes utilizadas pueden ser ilustrativas.\n\n'
                '**3. Limitación de Responsabilidad**\n'
                '"Tuc Comercial" actúa únicamente como un intermediario. No somos responsables de las transacciones, acuerdos o disputas que puedan surgir entre los usuarios y los comercios.\n\n'
                '**4. Modificaciones**\n'
                'Nos reservamos el derecho de modificar estos términos y condiciones en cualquier momento.'
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Cerrar'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}