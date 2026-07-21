import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../data/models/product_model.dart';
import '../models/sales_model.dart';
import 'pdf_helper.dart';

class ReportExportService {
  Future<String> exportInventoryValuation(List<ProductModel> products) async {
    final pdf = pw.Document();

    final totalValuation = products.fold<double>(0, (sum, p) => sum + (p.stock * p.price));

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (pw.Context context) => pw.Container(
          alignment: pw.Alignment.centerRight,
          margin: const pw.EdgeInsets.only(bottom: 10),
          decoration: const pw.BoxDecoration(
            border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey300, width: 0.5)),
          ),
          padding: const pw.EdgeInsets.only(bottom: 5),
          child: pw.Text('INVENTRA • INVENTORY VALUATION', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
        ),
        footer: (pw.Context context) => pw.Container(
          alignment: pw.Alignment.center,
          margin: const pw.EdgeInsets.only(top: 15),
          child: pw.Text('Page ${context.pageNumber}', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey500)),
        ),
        build: (pw.Context context) => [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Inventory Valuation Report', style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#1a237e'))),
                  pw.SizedBox(height: 4),
                  pw.Text('Workspace Catalog Status Summary', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text('Generated On:', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey500)),
                  pw.Text(DateTime.now().toLocal().toString().split('.')[0], style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 15),
          pw.Divider(color: PdfColor.fromHex('#1a237e'), thickness: 1.5),
          pw.SizedBox(height: 15),
          pw.TableHelper.fromTextArray(
            headers: ['ID', 'Name', 'Category', 'Stock', 'Price', 'Total Value'],
            data: products.isEmpty
                ? [
                    ['-', 'No products available', '-', '-', '-', '-']
                  ]
                : products.map((p) => [
                    p.id?.toString() ?? 'N/A',
                    p.name,
                    p.category,
                    p.stock.toString(),
                    '\$${p.price.toStringAsFixed(2)}',
                    '\$${(p.stock * p.price).toStringAsFixed(2)}',
                  ]).toList(),
            border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white, fontSize: 10),
            headerDecoration: const pw.BoxDecoration(color: PdfColor.fromInt(0xFF1A237E)),
            cellStyle: const pw.TextStyle(fontSize: 9),
            cellHeight: 25,
            cellAlignment: pw.Alignment.centerLeft,
            cellAlignments: {
              0: pw.Alignment.center,
              3: pw.Alignment.centerRight,
              4: pw.Alignment.centerRight,
              5: pw.Alignment.centerRight,
            },
          ),
          pw.SizedBox(height: 20),
          pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Container(
              padding: const pw.EdgeInsets.symmetric(horizontal: 15, vertical: 8),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColor.fromHex('#1a237e'), width: 1),
                color: PdfColor.fromHex('#f5f5f5'),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
              ),
              child: pw.Text(
                'Total Portfolio Value: \$${totalValuation.toStringAsFixed(2)}',
                style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#1a237e')),
              ),
            ),
          ),
        ],
      ),
    );

    final Uint8List bytes = await pdf.save();
    return saveAndOpenPdf(bytes, 'inventory_valuation_report.pdf');
  }

  Future<String> exportSalesMomentum(List<SalesModel> sales) async {
    final pdf = pw.Document();
    final totalRevenue = sales.fold<double>(0, (sum, s) => sum + s.amount);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (pw.Context context) => pw.Container(
          alignment: pw.Alignment.centerRight,
          margin: const pw.EdgeInsets.only(bottom: 10),
          decoration: const pw.BoxDecoration(
            border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey300, width: 0.5)),
          ),
          padding: const pw.EdgeInsets.only(bottom: 5),
          child: pw.Text('INVENTRA • SALES MOMENTUM', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
        ),
        footer: (pw.Context context) => pw.Container(
          alignment: pw.Alignment.center,
          margin: const pw.EdgeInsets.only(top: 15),
          child: pw.Text('Page ${context.pageNumber}', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey500)),
        ),
        build: (pw.Context context) => [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Sales Momentum Report', style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#2e7d32'))),
                  pw.SizedBox(height: 4),
                  pw.Text('Summary of realized revenue and order fulfillments', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text('Generated On:', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey500)),
                  pw.Text(DateTime.now().toLocal().toString().split('.')[0], style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 15),
          pw.Divider(color: PdfColor.fromHex('#2e7d32'), thickness: 1.5),
          pw.SizedBox(height: 15),
          pw.TableHelper.fromTextArray(
            headers: ['Order ID', 'Client Name', 'Date', 'Amount', 'Status'],
            data: sales.isEmpty
                ? [
                    ['-', 'No sales transactions recorded', '-', '-', '-']
                  ]
                : sales.map((s) => [
                    s.id,
                    s.clientName,
                    s.createdAt.toIso8601String().substring(0, 10),
                    '\$${s.amount.toStringAsFixed(2)}',
                    s.status,
                  ]).toList(),
            border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white, fontSize: 10),
            headerDecoration: const pw.BoxDecoration(color: PdfColor.fromInt(0xFF2E7D32)),
            cellStyle: const pw.TextStyle(fontSize: 9),
            cellHeight: 25,
            cellAlignment: pw.Alignment.centerLeft,
            cellAlignments: {
              0: pw.Alignment.center,
              2: pw.Alignment.center,
              3: pw.Alignment.centerRight,
              4: pw.Alignment.center,
            },
          ),
          pw.SizedBox(height: 20),
          pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Container(
              padding: const pw.EdgeInsets.symmetric(horizontal: 15, vertical: 8),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColor.fromHex('#2e7d32'), width: 1),
                color: PdfColor.fromHex('#f5f5f5'),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
              ),
              child: pw.Text(
                'Total Realized Revenue: \$${totalRevenue.toStringAsFixed(2)}',
                style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#2e7d32')),
              ),
            ),
          ),
        ],
      ),
    );

    final Uint8List bytes = await pdf.save();
    return saveAndOpenPdf(bytes, 'sales_momentum_report.pdf');
  }

  Future<String> exportReorderAlerts(List<ProductModel> products) async {
    final pdf = pw.Document();
    final lowStockItems = products.where((p) => p.stock <= 5).toList();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (pw.Context context) => pw.Container(
          alignment: pw.Alignment.centerRight,
          margin: const pw.EdgeInsets.only(bottom: 10),
          decoration: const pw.BoxDecoration(
            border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey300, width: 0.5)),
          ),
          padding: const pw.EdgeInsets.only(bottom: 5),
          child: pw.Text('INVENTRA • REORDER ALERTS', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
        ),
        footer: (pw.Context context) => pw.Container(
          alignment: pw.Alignment.center,
          margin: const pw.EdgeInsets.only(top: 15),
          child: pw.Text('Page ${context.pageNumber}', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey500)),
        ),
        build: (pw.Context context) => [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Reorder Alerts Report', style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#c62828'))),
                  pw.SizedBox(height: 4),
                  pw.Text('Items requiring critical restocking attention (stock <= 5)', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text('Generated On:', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey500)),
                  pw.Text(DateTime.now().toLocal().toString().split('.')[0], style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 15),
          pw.Divider(color: PdfColor.fromHex('#c62828'), thickness: 1.5),
          pw.SizedBox(height: 15),
          pw.TableHelper.fromTextArray(
            headers: ['ID', 'Name', 'Category', 'Current Stock', 'Supplier'],
            data: lowStockItems.isEmpty
                ? [
                    ['-', 'All items healthy (no critical shortages)', '-', '-', '-']
                  ]
                : lowStockItems.map((p) => [
                    p.id?.toString() ?? 'N/A',
                    p.name,
                    p.category,
                    p.stock.toString(),
                    p.supplier,
                  ]).toList(),
            border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white, fontSize: 10),
            headerDecoration: const pw.BoxDecoration(color: PdfColor.fromInt(0xFFC62828)),
            cellStyle: const pw.TextStyle(fontSize: 9),
            cellHeight: 25,
            cellAlignment: pw.Alignment.centerLeft,
            cellAlignments: {
              0: pw.Alignment.center,
              3: pw.Alignment.centerRight,
            },
          ),
        ],
      ),
    );

    final Uint8List bytes = await pdf.save();
    return saveAndOpenPdf(bytes, 'reorder_alerts_report.pdf');
  }
}
