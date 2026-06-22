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
        build: (pw.Context context) => [
          pw.Header(
            level: 0,
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Inventory Valuation Report', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                pw.Text(DateTime.now().toIso8601String().substring(0, 10)),
              ],
            ),
          ),
          pw.SizedBox(height: 12),
          pw.Paragraph(text: 'This report lists all products currently stored in the workspace inventory including total valuations and stock quantities.'),
          pw.SizedBox(height: 16),
          pw.TableHelper.fromTextArray(
            headers: ['ID', 'Name', 'Category', 'Stock', 'Price', 'Total Value'],
            data: products.map((p) => [
              p.id?.toString() ?? 'N/A',
              p.name,
              p.category,
              p.stock.toString(),
              '\$${p.price.toStringAsFixed(2)}',
              '\$${(p.stock * p.price).toStringAsFixed(2)}',
            ]).toList(),
          ),
          pw.SizedBox(height: 20),
          pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Text(
              'Total Portfolio Value: \$${totalValuation.toStringAsFixed(2)}',
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
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
        build: (pw.Context context) => [
          pw.Header(
            level: 0,
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Sales Momentum Report', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                pw.Text(DateTime.now().toIso8601String().substring(0, 10)),
              ],
            ),
          ),
          pw.SizedBox(height: 12),
          pw.Paragraph(text: 'This report summarizes customer transactions, client orders, and realized revenue margins.'),
          pw.SizedBox(height: 16),
          pw.TableHelper.fromTextArray(
            headers: ['Order ID', 'Client Name', 'Date', 'Amount', 'Status'],
            data: sales.map((s) => [
              s.id,
              s.clientName,
              s.createdAt.toIso8601String().substring(0, 10),
              '\$${s.amount.toStringAsFixed(2)}',
              s.status,
            ]).toList(),
          ),
          pw.SizedBox(height: 20),
          pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Text(
              'Total Realized Revenue: \$${totalRevenue.toStringAsFixed(2)}',
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
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
        build: (pw.Context context) => [
          pw.Header(
            level: 0,
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Reorder Alerts Report', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                pw.Text(DateTime.now().toIso8601String().substring(0, 10)),
              ],
            ),
          ),
          pw.SizedBox(height: 12),
          pw.Paragraph(text: 'The following low stock catalog items have dropped below the threshold of 5 units. Reordering is highly recommended.'),
          pw.SizedBox(height: 16),
          pw.TableHelper.fromTextArray(
            headers: ['ID', 'Name', 'Category', 'Current Stock', 'Supplier'],
            data: lowStockItems.map((p) => [
              p.id?.toString() ?? 'N/A',
              p.name,
              p.category,
              p.stock.toString(),
              p.supplier,
            ]).toList(),
          ),
        ],
      ),
    );

    final Uint8List bytes = await pdf.save();
    return saveAndOpenPdf(bytes, 'reorder_alerts_report.pdf');
  }
}
