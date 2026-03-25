import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_application_1/features/company/data/manage_employees_service.dart';

class ManageEmployeesScreen extends StatefulWidget {
  const ManageEmployeesScreen({super.key});

  @override
  State<ManageEmployeesScreen> createState() => _ManageEmployeesScreenState();
}

class _ManageEmployeesScreenState extends State<ManageEmployeesScreen> {
  List employees = [];
  List filteredEmployees = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadEmployees();
  }

  Future<void> loadEmployees() async {
    final data = await ManageEmployeesService.getEmployees();

    setState(() {
      employees = data;
      filteredEmployees = data;
      loading = false;
    });
  }

  void searchEmployee(String value) {
    setState(() {
      filteredEmployees = employees.where((emp) {
        return emp['name'].toLowerCase().contains(value.toLowerCase());
      }).toList();
    });
  }

  void _confirmDeleteEmployee(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Delete Employee?"),
        content: const Text("This action cannot be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              await ManageEmployeesService.deleteEmployee(id);
              if (!mounted) return;
              Navigator.pop(context);
              loadEmployees();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Delete"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          "Employees",
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: const Color(0xFF1A1A1A),
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEmployeeDialog(context),
        backgroundColor: const Color(0xFF2563EB),
        icon: const Icon(Icons.add),
        label: const Text("Add Employee"),
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [

                /// SEARCH
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    onChanged: searchEmployee,
                    decoration: InputDecoration(
                      hintText: "Search employee",
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),

                /// EMPLOYEE LIST
                Expanded(
                  child: filteredEmployees.isEmpty
                      ? const Center(child: Text("No employees"))
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: filteredEmployees.length,
                          itemBuilder: (context, index) {
                            final emp = filteredEmployees[index];

                            return Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 8,
                                  )
                                ],
                              ),
                              child: Row(
                                children: [

                                  /// AVATAR
                                  const CircleAvatar(
                                    radius: 22,
                                    backgroundColor: Color(0xFF2563EB),
                                    child: Icon(
                                      Icons.person,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),

                                  const SizedBox(width: 12),

                                  /// INFO
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [

                                        Text(
                                          emp['name'],
                                          style: GoogleFonts.montserrat(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),

                                        const SizedBox(height: 2),

                                        Text(
                                          "ID: ${emp['id']}",
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),

                                        if (emp['phone'] != null)
                                          Text(
                                            emp['phone'],
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),

                                  /// ROLE
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: emp['role'] == "OWNER"
                                          ? Colors.orange
                                          : const Color(0xFF2563EB),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      emp['role'],
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),

                                  const SizedBox(width: 6),

                                  /// ACTIONS
                                  Row(
                                    children: [

                                      IconButton(
                                        icon: const Icon(Icons.edit,
                                            size: 20,
                                            color: Color(0xFF2563EB)),
                                        onPressed: () =>
                                            _showEditEmployeeDialog(emp),
                                      ),

                                      IconButton(
                                        icon: const Icon(Icons.delete,
                                            size: 20, color: Colors.red),
                                        onPressed: () =>
                                            _confirmDeleteEmployee(emp['id']),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }

  /// ADD EMPLOYEE
  void _showAddEmployeeDialog(BuildContext context) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    final passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Text("Add Employee"),
        content: SingleChildScrollView(
          child: Column(
            children: [

              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Name"),
              ),

              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: "Email"),
              ),

              TextField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: "Phone"),
              ),

              TextField(
                controller: passwordController,
                decoration: const InputDecoration(labelText: "Password"),
                obscureText: true,
              ),
            ],
          ),
        ),
        actions: [

          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),

          ElevatedButton(
            onPressed: () async {
              await ManageEmployeesService.createEmployee(
                name: nameController.text,
                email: emailController.text,
                phone: phoneController.text,
                password: passwordController.text,
              );

              if (context.mounted) {
                Navigator.pop(context);
                loadEmployees();
              }
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  /// EDIT EMPLOYEE
  void _showEditEmployeeDialog(Map emp) {
    final nameController = TextEditingController(text: emp['name']);
    final emailController = TextEditingController(text: emp['email'] ?? "");
    final phoneController = TextEditingController(text: emp['phone'] ?? "");

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Text("Edit Employee"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Name"),
            ),

            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),

            TextField(
              controller: phoneController,
              decoration: const InputDecoration(labelText: "Phone"),
            ),
          ],
        ),
        actions: [

          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),

          ElevatedButton(
            onPressed: () async {
              await ManageEmployeesService.updateEmployee(
                id: emp['id'],
                name: nameController.text,
                email: emailController.text,
                phone: phoneController.text,
              );

              if (!mounted) return;
              Navigator.pop(context);
              loadEmployees();
            },
            child: const Text("Update"),
          ),
        ],
      ),
    );
  }
}