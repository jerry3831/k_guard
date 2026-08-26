import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/scanner_bloc.dart';
import '../providers/scanner_event.dart';
import '../providers/scanner_state.dart';
import '../widgets/camera_overlay.dart';
import '../../../../core/theme/app_colors.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen>
    with WidgetsBindingObserver {
  CameraController? _cameraController;
  List<CameraDescription> _cameras = [];
  bool _cameraInitialized = false;
  int _selectedCameraIndex = 0;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCamera();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }
    if (state == AppLifecycleState.inactive) {
      _cameraController?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initCamera(cameraIndex: _selectedCameraIndex);
    }
  }

  Future<void> _initCamera({int cameraIndex = 0}) async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) return;

      _selectedCameraIndex = cameraIndex.clamp(0, _cameras.length - 1);
      _cameraController = CameraController(
        _cameras[_selectedCameraIndex],
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _cameraController!.initialize();

      if (mounted) {
        setState(() => _cameraInitialized = true);
      }
    } catch (e) {
      debugPrint('Camera init error: $e');
    }
  }

  Future<void> _flipCamera() async {
    final nextIndex = (_selectedCameraIndex + 1) % _cameras.length;
    await _cameraController?.dispose();
    setState(() => _cameraInitialized = false);
    await _initCamera(cameraIndex: nextIndex);
    if (mounted) {
      context.read<ScannerBloc>().add(const ScannerFlipCamera());
    }
  }

  Future<void> _captureImage() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }
    try {
      final xFile = await _cameraController!.takePicture();
      if (mounted) {
        context
            .read<ScannerBloc>()
            .add(ScannerImageCaptured(File(xFile.path)));
      }
    } catch (e) {
      debugPrint('Capture error: $e');
    }
  }

  Future<void> _pickFromGallery() async {
    final xFiles = await _picker.pickMultiImage(
      imageQuality: 90,
    );
    if (xFiles.isNotEmpty && mounted) {
      for (var xFile in xFiles) {
        context.read<ScannerBloc>().add(ScannerImagePicked(File(xFile.path)));
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.dispose();
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ScannerBloc, ScannerState>(
      listener: (context, state) {
        if (state is ScannerSuccess) {
          Navigator.of(context).pushNamed(
            '/scan-result',
            arguments: state.result,
          );
        }
        if (state is ScannerFailure) {
          _showErrorSnackbar(context, state.message);
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.scannerBackground,
          extendBodyBehindAppBar: true,
          appBar: _buildAppBar(context),
          body: Stack(
            fit: StackFit.expand,
            children: [
              _buildCameraPreview(),

              _buildVignette(),

              _buildViewfinderLayer(),

              _buildControlsLayer(state),

              if (state is ScannerAnalyzing) _buildAnalyzingOverlay(),
            ],
          ),
          bottomNavigationBar: _buildBottomNav(context),
        );
      },
    );
  }


  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.black38,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.close, color: Colors.white, size: 18),
        ),
        onPressed: () => Navigator.of(context).maybePop(),
      ),
      title: const Text(
        'Scan Currency',
        style: AppTextStyles.screenTitle,
      ),
      centerTitle: true,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: IconButton(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.black38,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.flashlight_on_outlined,
                  color: Colors.white, size: 18),
            ),
            onPressed: () {
              _cameraController?.setFlashMode(FlashMode.torch);
            },
          ),
        ),
      ],
    );
  }


  Widget _buildCameraPreview() {
    if (!_cameraInitialized || _cameraController == null) {
      return Container(color: AppColors.scannerBackground);
    }
    return CameraPreview(_cameraController!);
  }

  Widget _buildVignette() {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 1.2,
          colors: [
            Colors.transparent,
            Colors.black.withOpacity(0.65),
          ],
          stops: const [0.55, 1.0],
        ),
      ),
    );
  }


  Widget _buildViewfinderLayer() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 40), // offset for appbar
        if (_cameraInitialized)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.hintBubble,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.crop_free, color: Colors.white60, size: 14),
                const SizedBox(width: 6),
                Text(
                  'Position currency within frame',
                  style: AppTextStyles.hintText.copyWith(color: Colors.white70),
                ),
              ],
            ),
          ),
      ],
    );
  }


  Widget _buildControlsLayer(ScannerState state) {
    final isIdle = state is ScannerIdle;
    final stagedImages = isIdle ? (state as ScannerIdle).stagedImages : <File>[];

    return Positioned(
      left: 0,
      right: 0,
      bottom: 24, // closer to bottom nav
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (stagedImages.isNotEmpty)
            Container(
              height: 72,
              margin: const EdgeInsets.only(bottom: 16),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: stagedImages.length,
                itemBuilder: (context, index) {
                  return Stack(
                    children: [
                      GestureDetector(
                        onTap: () => _showImagePreview(stagedImages, index),
                        child: Container(
                          width: 56,
                          margin: const EdgeInsets.only(right: 12, top: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.primaryBlue, width: 2),
                            image: DecorationImage(
                              image: FileImage(stagedImages[index]),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 0,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => context.read<ScannerBloc>().add(ScannerImageRemoved(index)),
                          child: Container(
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.redAccent,
                            ),
                            child: const Icon(Icons.close, color: Colors.white, size: 16),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: isIdle ? _pickFromGallery : null,
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.12),
                    border: Border.all(color: Colors.white30, width: 1.5),
                  ),
                  child: const Icon(Icons.upload_rounded,
                      color: Colors.white, size: 24),
                ),
              ),

              const SizedBox(width: 32),

              GestureDetector(
                onTap: isIdle ? _captureImage : null,
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primaryBlue,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryBlue.withOpacity(0.4),
                        blurRadius: 20,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.camera_alt_rounded,
                      color: Colors.white, size: 28),
                ),
              ),

              const SizedBox(width: 32),

              if (stagedImages.isNotEmpty)
                GestureDetector(
                  onTap: () => context.read<ScannerBloc>().add(const ScannerStartInference()),
                  child: Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.authentic,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.authentic.withOpacity(0.4),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.check_rounded,
                        color: Colors.white, size: 28),
                  ),
                )
              else
                const SizedBox(width: 52, height: 52),
            ],
          ),

          if (stagedImages.isNotEmpty) ...[
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => context.read<ScannerBloc>().add(const ScannerClearImages()),
              child: Text(
                'Retake All',
                style: AppTextStyles.hintText.copyWith(color: Colors.redAccent, fontWeight: FontWeight.bold),
              ),
            ),
          ] else ...[
            const SizedBox(height: 16),
            Text(
              'Tap to capture or upload an image of the currency note',
              style: AppTextStyles.hintText.copyWith(
                color: Colors.white54,
                fontSize: 11,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }


  Widget _buildAnalyzingOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.6),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          decoration: BoxDecoration(
            color: AppColors.scannerSurface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(
                valueColor:
                    AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
                strokeWidth: 3,
              ),
              const SizedBox(height: 16),
              Text(
                'Analyzing image...',
                style: AppTextStyles.hintText
                    .copyWith(color: Colors.white, fontSize: 15),
              ),
              const SizedBox(height: 4),
              Text(
                'Connecting to cloud...',
                style: AppTextStyles.hintText
                    .copyWith(color: Colors.white54, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildBottomNav(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, -2),
            ),
        ],
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavItem(icon: Icons.home_outlined, active: false,
                onTap: () => Navigator.of(context).pushReplacementNamed('/home')),
            _NavItem(icon: Icons.camera_alt_outlined, active: true,
                onTap: () {}),
            _NavItem(icon: Icons.history, active: false,
                onTap: () =>
                    Navigator.of(context).pushReplacementNamed('/history')),
            _NavItem(icon: Icons.menu_book_outlined,
                active: false, onTap: () {}),
            _NavItem(icon: Icons.settings_outlined,
                active: false,
                onTap: () =>
                    Navigator.of(context).pushReplacementNamed('/settings')),
          ],
        ),
      ),
    );
  }

  void _showErrorSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.counterfeit,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _showImagePreview(List<File> images, int initialIndex) {
    showDialog(
      context: context,
      useSafeArea: false,
      barrierColor: Colors.black.withOpacity(0.95),
      builder: (context) {
        final pageController = PageController(initialPage: initialIndex);
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(
            fit: StackFit.expand,
            children: [
              PageView.builder(
                controller: pageController,
                itemCount: images.length,
                itemBuilder: (context, index) {
                  return Center(
                    child: InteractiveViewer(
                      child: Image.file(images[index]),
                    ),
                  );
                },
              ),
              Positioned(
                top: MediaQuery.of(context).padding.top + 16,
                right: 16,
                child: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white30),
                    ),
                    child: const Icon(Icons.close, color: Colors.white, size: 24),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}




class _NavItem extends StatelessWidget {
  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = active 
        ? Theme.of(context).colorScheme.primary 
        : (isDark ? Colors.white54 : AppColors.textSecondary);
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 26),
              const SizedBox(height: 4),
              Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: active ? color : Colors.transparent,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
