import 'package:flutter/material.dart';

class AddCardView extends StatefulWidget {
  const AddCardView({super.key});

  @override
  State<AddCardView> createState() => _AddCardViewState();
}

class _AddCardViewState extends State<AddCardView> {
  TextEditingController txtCardNumber = TextEditingController();
  TextEditingController txtCardMonth = TextEditingController();
  TextEditingController txtCardYear = TextEditingController();
  TextEditingController txtCardCode = TextEditingController();
  TextEditingController txtFirstName = TextEditingController();
  TextEditingController txtLastName = TextEditingController();

  @override
  void dispose() {
    txtCardNumber.dispose();
    txtCardMonth.dispose();
    txtCardYear.dispose();
    txtCardCode.dispose();
    txtFirstName.dispose();
    txtLastName.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // พื้นหลังโปร่งใส
      body: Stack(
        children: [
          Container(color: Colors.transparent), // พื้นหลังของหน้าจอ
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      const Text(
                        "Add Credit/Debit Card",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w700),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(
                          Icons.close,
                          color: Colors.black,
                          size: 25,
                        ),
                      ),
                    ],
                  ),
                  const Divider(
                    color: Colors.grey,
                    height: 1,
                  ),
                  const SizedBox(height: 15),
                  // ฟิลด์สำหรับกรอกหมายเลขบัตร
                  TextField(
                    controller: txtCardNumber,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: "Card Number",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                    ),
                  ),
                  const SizedBox(height: 15),
                  // ฟิลด์สำหรับวันหมดอายุบัตร
                  Row(
                    children: [
                      SizedBox(
                        width: 100,
                        child: TextField(
                          controller: txtCardMonth,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: "MM",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            filled: true,
                            fillColor: Colors.grey[200],
                          ),
                        ),
                      ),
                      const SizedBox(width: 25),
                      SizedBox(
                        width: 100,
                        child: TextField(
                          controller: txtCardYear,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: "YYYY",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            filled: true,
                            fillColor: Colors.grey[200],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  // ฟิลด์สำหรับรหัสความปลอดภัยของบัตร
                  TextField(
                    controller: txtCardCode,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: "Card Security Code",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                    ),
                  ),
                  const SizedBox(height: 15),
                  // ฟิลด์สำหรับชื่อผู้ถือบัตร
                  TextField(
                    controller: txtFirstName,
                    decoration: InputDecoration(
                      hintText: "First Name",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                    ),
                  ),
                  const SizedBox(height: 15),
                  // ฟิลด์สำหรับนามสกุลผู้ถือบัตร
                  TextField(
                    controller: txtLastName,
                    decoration: InputDecoration(
                      hintText: "Last Name",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                    ),
                  ),
                  const SizedBox(height: 25),
                  ElevatedButton.icon(
                    onPressed: () {
                      // ตรวจสอบข้อมูลที่กรอก
                      if (txtCardNumber.text.isEmpty || 
                          txtCardMonth.text.isEmpty || 
                          txtCardYear.text.isEmpty || 
                          txtCardCode.text.isEmpty || 
                          txtFirstName.text.isEmpty || 
                          txtLastName.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please fill in all fields')),
                        );
                        return; // ออกจากฟังก์ชันหากมีฟิลด์ว่าง
                      }
                      
                      // สามารถดำเนินการบันทึกบัตรที่นี่
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Card added successfully')),
                      );

                      // ปิดหน้าจอ AddCardView
                      Navigator.pop(context);
                    },
                    label: const Text(
                      "Add Card",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
