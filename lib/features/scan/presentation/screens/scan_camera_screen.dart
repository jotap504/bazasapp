import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:io';

import 'package:bazas/core/theme/app_theme.dart';
import 'package:bazas/core/router/app_router.dart';
import 'package:bazas/features/scan/presentation/controllers/scan_controller.dart';

class ScanCameraScreen extends ConsumerStatefulWidget {
  const ScanCameraScreen({super.key, required this.groupId, this.date});
  final String groupId;
  final String? date;

  @override
  ConsumerState<ScanCameraScreen> createState() => _ScanCameraScreenState();
}

class _ScanCameraScreenState extends ConsumerState<ScanCameraScreen> {
  CameraController? _controller;
  bool _isInitializing = true;
  bool _isTakingPicture = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
    // Iniciar el estado del controller
    Future.delayed(Duration.zero, () {
      ref.read(scanControllerProvider.notifier).setGroupId(widget.groupId);
      if (widget.date != null) {
        final date = DateTime.tryParse(widget.date!);
        if (date != null) {
          ref.read(scanControllerProvider.notifier).setPlayedAt(date);
        }
      }
    });
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) return;

    _controller = CameraController(
      cameras.first,
      ResolutionPreset.high,
      enableAudio: false,
    );

    try {
      await _controller!.initialize();
      if (mounted) setState(() => _isInitializing = false);
    } catch (e) {
      debugPrint('Error cámara: $e');
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized || _isTakingPicture) return;

    setState(() => _isTakingPicture = true);

    try {
      final image = await _controller!.takePicture();
      final file = File(image.path);
      
      ref.read(scanControllerProvider.notifier).setCapturedImage(file);
      
      if (mounted) {
        context.push(AppRoutes.scanLoading);
        setState(() => _isTakingPicture = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isTakingPicture = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al tomar foto: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitializing) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // PREVIEW
          Positioned.fill(
            child: CameraPreview(_controller!),
          ),

          // OVERLAY / FRAME
          Positioned.fill(
            child: _CameraOverlay(),
          ),

          // CONTROLES
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Flexible(
                  child: IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.close, color: Colors.white, size: 30),
                  ),
                ),
                GestureDetector(
                  onTap: _takePicture,
                  child: Container(
                    height: 80,
                    width: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.neonGreen, width: 4),
                    ),
                    child: Center(
                      child: _isTakingPicture 
                        ? const CircularProgressIndicator(color: AppColors.neonGreen)
                        : Container(
                            height: 60,
                            width: 60,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                          ),
                    ),
                  ),
                ),
                const Flexible(child: SizedBox(width: 48)), // Placeholder para balancear el Row
              ],
            ),
          ),
          
          Positioned(
            top: 60,
            left: 24,
            right: 24,
            child: Text(
              'ENCUADRA LA PLANILLA',
              textAlign: TextAlign.center,
              style: AppTextStyles.rajdhani(
                color: AppColors.neonGreen,
                fontSize: 20,
                fontWeight: FontWeight.w800,
                letterSpacing: 2.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CameraOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: ShapeDecoration(
        shape: _ScannerOverlayShape(
          borderColor: AppColors.neonGreen,
          borderWidth: 2.0,
          borderRadius: 12.0,
          borderLength: 40.0,
          cutOutSize: (MediaQuery.of(context).size.width * 0.85),
        ),
      ),
    );
  }
}

class _ScannerOverlayShape extends ShapeBorder {
  const _ScannerOverlayShape({
    required this.borderColor,
    required this.borderWidth,
    required this.borderRadius,
    required this.borderLength,
    required this.cutOutSize,
  });

  final Color borderColor;
  final double borderWidth;
  final double borderRadius;
  final double borderLength;
  final double cutOutSize;

  @override
  EdgeInsetsGeometry get dimensions => const EdgeInsets.all(10);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) => Path();

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) => Path();

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    final width = rect.width;
    final height = rect.height;

    final backgroundPaint = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    final cutOutRect = Rect.fromCenter(
      center: Offset(width / 2, height / 2),
      width: cutOutSize,
      height: cutOutSize * 1.4, // Más alta que ancha para planillas
    );

    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(rect),
        Path()..addRRect(RRect.fromRectAndRadius(cutOutRect, Radius.circular(borderRadius))),
      ),
      backgroundPaint,
    );

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    // Dibujar solo las esquinas
    final path = Path();
    
    // Top Left
    path.moveTo(cutOutRect.left, cutOutRect.top + borderLength);
    path.lineTo(cutOutRect.left, cutOutRect.top + borderRadius);
    path.arcToPoint(Offset(cutOutRect.left + borderRadius, cutOutRect.top), radius: Radius.circular(borderRadius));
    path.lineTo(cutOutRect.left + borderLength, cutOutRect.top);

    // Top Right
    path.moveTo(cutOutRect.right - borderLength, cutOutRect.top);
    path.lineTo(cutOutRect.right - borderRadius, cutOutRect.top);
    path.arcToPoint(Offset(cutOutRect.right, cutOutRect.top + borderRadius), radius: Radius.circular(borderRadius));
    path.lineTo(cutOutRect.right, cutOutRect.top + borderLength);

    // Bottom Right
    path.moveTo(cutOutRect.right, cutOutRect.bottom - borderLength);
    path.lineTo(cutOutRect.right, cutOutRect.bottom - borderRadius);
    path.arcToPoint(Offset(cutOutRect.right - borderRadius, cutOutRect.bottom), radius: Radius.circular(borderRadius));
    path.lineTo(cutOutRect.right - borderLength, cutOutRect.bottom);

    // Bottom Left
    path.moveTo(cutOutRect.left + borderLength, cutOutRect.bottom);
    path.lineTo(cutOutRect.left + borderRadius, cutOutRect.bottom);
    path.arcToPoint(Offset(cutOutRect.left, cutOutRect.bottom - borderRadius), radius: Radius.circular(borderRadius));
    path.lineTo(cutOutRect.left, cutOutRect.bottom - borderLength);

    canvas.drawPath(path, borderPaint);
  }

  @override
  ShapeBorder scale(double t) => this;
}
