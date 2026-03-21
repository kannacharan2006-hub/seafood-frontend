import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {

  final _formKey = GlobalKey<FormState>();

  final TextEditingController companyController = TextEditingController();
  final TextEditingController ownerController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  bool isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _animationController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 600));

    _fadeAnimation =
        CurvedAnimation(parent: _animationController, curve: Curves.easeIn);

    _animationController.forward();
  }

  @override
  void dispose() {
    companyController.dispose();
    ownerController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> registerCompany() async {

    if (!_formKey.currentState!.validate()) return;

    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Passwords do not match"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    try {

      final result = await AuthService.registerCompany(
        companyName: companyController.text,
        ownerName: ownerController.text,
        email: emailController.text,
        password: passwordController.text,
        phone: phoneController.text,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);

    } catch (e) {

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ),
      );
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      body: FadeTransition(
        opacity: _fadeAnimation,

        child: SafeArea(

          child: Center(

            child: SingleChildScrollView(

              padding: const EdgeInsets.symmetric(horizontal: 24),

              child: ConstrainedBox(

                constraints: const BoxConstraints(maxWidth: 420),

                child: Form(

                  key: _formKey,

                  child: Column(

                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [

                      const SizedBox(height: 40),

                      /// TITLE
                      const Text(
                        "Create Company Account",
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),

                      const SizedBox(height: 6),

                      Text(
                        "Register your business to continue",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),

                      const SizedBox(height: 32),

                      _buildTextField(
                        label: "Company Name",
                        hint: "Enter company name",
                        icon: Icons.business,
                        controller: companyController,
                        validator: (value) =>
                            value?.isEmpty ?? true ? "Company name required" : null,
                      ),

                      _buildTextField(
                        label: "Owner Name",
                        hint: "Enter owner name",
                        icon: Icons.person,
                        controller: ownerController,
                        validator: (value) =>
                            value?.isEmpty ?? true ? "Owner name required" : null,
                      ),

                      _buildTextField(
                        label: "Email",
                        hint: "Enter business email",
                        icon: Icons.email_outlined,
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {

                          if (value?.isEmpty ?? true) return "Email required";

                          if (!RegExp(
                                  r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                              .hasMatch(value!)) {
                            return "Enter valid email";
                          }

                          return null;
                        },
                      ),

                      _buildTextField(
                        label: "Phone Number",
                        hint: "Enter phone number",
                        icon: Icons.phone,
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(10),
                        ],
                        validator: (value) {

                          if (value?.isEmpty ?? true) return "Phone required";

                          if (value!.length != 10) {
                            return "Enter valid 10 digit phone";
                          }

                          return null;
                        },
                      ),

                      _buildTextField(
                        label: "Password",
                        hint: "Create password",
                        icon: Icons.lock_outline,
                        controller: passwordController,
                        obscureText: _obscurePassword,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        validator: (value) {

                          if (value?.isEmpty ?? true) return "Password required";

                          if (value!.length < 8) {
                            return "Minimum 8 characters";
                          }

                          return null;
                        },
                      ),

                      _buildTextField(
                        label: "Confirm Password",
                        hint: "Re-enter password",
                        icon: Icons.lock_outline,
                        controller: confirmPasswordController,
                        obscureText: _obscureConfirmPassword,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureConfirmPassword =
                                  !_obscureConfirmPassword;
                            });
                          },
                        ),
                        validator: (value) {

                          if (value?.isEmpty ?? true) return "Confirm password";

                          if (value != passwordController.text) {
                            return "Passwords do not match";
                          }

                          return null;
                        },
                      ),

                      const SizedBox(height: 30),

                      /// REGISTER BUTTON
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : registerCompany,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4CAF50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  "Register Company",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 26),

                      /// LOGIN LINK
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [

                          Text(
                            "Already have an account?",
                            style: TextStyle(color: Colors.grey[600]),
                          ),

                          const SizedBox(width: 6),

                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: const Text(
                              "Login",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF4CAF50),
                              ),
                            ),
                          ),

                        ],
                      ),

                      const SizedBox(height: 20),

                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),

      child: Column(

        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),

          const SizedBox(height: 8),

          TextFormField(

            controller: controller,
            keyboardType: keyboardType,
            obscureText: obscureText,
            inputFormatters: inputFormatters,
            validator: validator,

            decoration: InputDecoration(

              prefixIcon: Icon(icon, color: const Color(0xFF4CAF50)),

              suffixIcon: suffixIcon,

              hintText: hint,

              filled: true,

              fillColor: Colors.white,

              contentPadding:
                  const EdgeInsets.symmetric(vertical: 18, horizontal: 16),

              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),

              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),

              focusedBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(14)),
                borderSide: BorderSide(
                  color: Color(0xFF4CAF50),
                  width: 2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}