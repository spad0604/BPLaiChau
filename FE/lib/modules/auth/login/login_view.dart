import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../widgets/app_text_field.dart';
import '../../../widgets/app_button.dart';
import 'login_controller.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    // Split screen: Left Image, Right Form
    return Scaffold(
      body: Row(
        children: [
          // Left Side - Image
          Expanded(
            flex: 5,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Obx(() {
                  final fallback = 'https://images.unsplash.com/photo-1506744038136-46273834b3fb?q=80&w=2070&auto=format&fit=crop';
                  final urls = controller.bannerUrls;
                  final idx = controller.bannerIndex.value;
                  final url = (urls.isNotEmpty && idx >= 0 && idx < urls.length) ? urls[idx] : fallback;
                  Widget buildImage(String imageUrl) {
                    return SizedBox.expand(
                      child: Image.network(
                        imageUrl,
                        key: ValueKey(imageUrl),
                        fit: BoxFit.cover,
                        alignment: Alignment.center,
                        errorBuilder: (c, e, st) => Image.network(
                          fallback,
                          fit: BoxFit.cover,
                          alignment: Alignment.center,
                        ),
                      ),
                    );
                  }

                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 450),
                    switchInCurve: Curves.easeOut,
                    switchOutCurve: Curves.easeIn,
                    layoutBuilder: (currentChild, previousChildren) {
                      return Stack(
                        fit: StackFit.expand,
                        children: <Widget>[
                          ...previousChildren,
                          if (currentChild != null) currentChild,
                        ],
                      );
                    },
                    child: buildImage(url),
                  );
                }),
                Container(color: Colors.black.withAlpha(102)),
                const Positioned(
                  bottom: 60,
                  left: 60,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Vững chủ quyền,\nAn ninh biên giới.",
                        style: TextStyle(
                            color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold, height: 1.2),
                      ),
                      SizedBox(height: 16),
                      SizedBox(
                        width: 400,
                        child: Text(
                          "Hệ thống quản lý, giám sát và điều hành tác chiến điện tử. "
                          "Đảm bảo an toàn thông tin và bảo mật dữ liệu quốc gia.",
                          style: TextStyle(color: Colors.white70, fontSize: 14, height: 1.5),
                        ),
                      ),
                      SizedBox(height: 30),
                    ],
                  ),
                )
              ],
            ),
          ),
          // Right Side - Login Form
          Expanded(
            flex: 4,
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 80),
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo: national emblem (SVG)
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Image.network(
                            'https://res.cloudinary.com/dhhdd4pkl/image/upload/v1769262279/Emblem_of_Vietnam_z1ltez.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        "CỘNG HÒA XÃ HỘI CHỦ NGHĨA VIỆT NAM\nĐộc lập - Tự do - Hạnh phúc",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        "BỘ CHỈ HUY BỘ ĐỘI BIÊN PHÒNG TỈNH LAI CHÂU",
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFCE1126)),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "HỆ THỐNG QUẢN LÝ VỤ VIỆC",
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1B4D3E)),
                      ),
                      const SizedBox(height: 48),

                      // Form
                      AppTextField(
                        label: "Số hiệu quân nhân / Tài khoản",
                        hint: "Nhập số hiệu hoặc tên đăng nhập",
                        prefixIcon: Icons.badge_outlined,
                        onChanged: (val) => controller.username.value = val,
                      ),
                      const SizedBox(height: 20),
                      Obx(() => AppTextField(
                        label: "Mật khẩu",
                        hint: "••••••••",
                        isPassword: controller.obscurePassword.value,
                        prefixIcon: Icons.lock_outline,
                        suffixIcon: IconButton(
                          icon: Icon(
                            controller.obscurePassword.value ? Icons.visibility_off : Icons.visibility,
                            color: Colors.grey,
                          ),
                          onPressed: controller.togglePassword,
                        ),
                        onChanged: (val) => controller.password.value = val,
                      )),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Checkbox(value: false, onChanged: (v) {}),
                              const Text("Ghi nhớ trên thiết bị này"),
                            ],
                          ),
                          TextButton(onPressed: () {}, child: const Text("Quên mật khẩu?")),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Obx(() => SizedBox(
                        width: double.infinity,
                        child: AppButton(
                          text: "ĐĂNG NHẬP",
                          onPressed: controller.login,
                          isLoading: controller.isLoadingRx.value,
                        ),
                      )),
                      const SizedBox(height: 32),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: const [
                            Icon(Icons.info_outline, color: Colors.blue),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                "Nếu gặp sự cố đăng nhập, vui lòng liên hệ Phòng Kỹ thuật (Ext: 102) hoặc gửi yêu cầu hỗ trợ.",
                                style: TextStyle(fontSize: 12, color: Colors.blue),
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
