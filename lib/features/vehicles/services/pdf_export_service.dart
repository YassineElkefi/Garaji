import 'dart:io';
import 'package:garaji/data/models/maintenance_entry.dart';
import 'package:garaji/data/models/vehicle.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:open_filex/open_filex.dart';

class PdfExportService {
  // App theme colors
  static final PdfColor primaryColor = PdfColor.fromHex('#1A237E');
  static final PdfColor secondaryColor = PdfColor.fromHex('#D4AF37');
  static final PdfColor surfaceColor = PdfColor.fromHex('#F5F7FA');
  static final PdfColor errorColor = PdfColor.fromHex('#C62828');
  static final PdfColor grey600 = PdfColor.fromHex('#616161');

  static Future<String> exportMaintenanceToPdf(
    Vehicle vehicle,
    List<MaintenanceEntry> entries,
  ) async {
    final pdf = pw.Document();

    // Sort entries by date (newest first)
    final sortedEntries = List<MaintenanceEntry>.from(entries)
      ..sort((a, b) => b.date.compareTo(a.date));

    // Calculate statistics
    final totalCost = entries.fold<double>(0, (sum, e) => sum + e.cost);
    final avgCost = entries.isEmpty ? 0.0 : totalCost / entries.length;

    // Group by category
    final Map<String, double> categoryTotals = {};
    final Map<String, int> categoryCount = {};
    for (var entry in entries) {
      categoryTotals[entry.category] =
          (categoryTotals[entry.category] ?? 0) + entry.cost;
      categoryCount[entry.category] = (categoryCount[entry.category] ?? 0) + 1;
    }

    // Add pages
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (context) => [
          _buildHeader(vehicle),
          pw.SizedBox(height: 20),
          _buildVehicleInfo(vehicle),
          pw.SizedBox(height: 20),
          _buildSummarySection(
            totalCost,
            avgCost,
            entries.length,
            categoryTotals,
            categoryCount,
          ),
          pw.SizedBox(height: 20),
          _buildMaintenanceTable(sortedEntries),
          pw.SizedBox(height: 20),
          _buildDetailedEntries(sortedEntries),
        ],
        footer: (context) => _buildFooter(context),
      ),
    );

    // Save to device storage
    final output = await getApplicationDocumentsDirectory();
    final fileName =
        'maintenance_${vehicle.brand}_${vehicle.model}_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.pdf';
    final file = File('${output.path}/$fileName');
    await file.writeAsBytes(await pdf.save());

    // Open the PDF file
    await OpenFilex.open(file.path);

    return file.path;
  }

  static pw.Widget _buildHeader(Vehicle vehicle) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: primaryColor,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'MAINTENANCE REPORT',
            style: pw.TextStyle(
              fontSize: 24,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            '${vehicle.brand} ${vehicle.model}',
            style: pw.TextStyle(
              fontSize: 18,
              color: PdfColors.white,
              fontFallback: [pw.Font.times()],
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            'Generated on ${DateFormat('MMMM dd, yyyy').format(DateTime.now())}',
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.white),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildVehicleInfo(Vehicle vehicle) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
        children: [
          _buildInfoItem('Brand', vehicle.brand),
          _buildInfoItem('Model', vehicle.model),
          _buildInfoItem('Year', vehicle.year.toString()),
          _buildInfoItem('Current Mileage', '${vehicle.mileage} km'),
        ],
      ),
    );
  }

  static pw.Widget _buildInfoItem(String label, String value) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Text(label, style: pw.TextStyle(fontSize: 10, color: grey600)),
        pw.SizedBox(height: 4),
        pw.Text(
          value,
          style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
        ),
      ],
    );
  }

  static pw.Widget _buildSummarySection(
    double totalCost,
    double avgCost,
    int entryCount,
    Map<String, double> categoryTotals,
    Map<String, int> categoryCount,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'SUMMARY',
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
            color: primaryColor,
          ),
        ),
        pw.SizedBox(height: 12),
        pw.Container(
          padding: const pw.EdgeInsets.all(16),
          decoration: pw.BoxDecoration(
            color: surfaceColor,
            borderRadius: pw.BorderRadius.circular(8),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryCard(
                'Total Spent',
                '${totalCost.toStringAsFixed(2)} DT',
                primaryColor,
              ),
              _buildSummaryCard(
                'Average Cost',
                '${avgCost.toStringAsFixed(2)} DT',
                secondaryColor,
              ),
              _buildSummaryCard(
                'Total Entries',
                entryCount.toString(),
                errorColor,
              ),
            ],
          ),
        ),
        pw.SizedBox(height: 12),
        if (categoryTotals.isNotEmpty) ...[
          pw.Text(
            'BY CATEGORY',
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
              color: grey600,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey300),
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Column(
              children: categoryTotals.entries.map((entry) {
                final percentage = (entry.value / totalCost * 100);
                return pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 8),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        '${entry.key} (${categoryCount[entry.key]} entries)',
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                      pw.Text(
                        '${entry.value.toStringAsFixed(2)} DT (${percentage.toStringAsFixed(1)}%)',
                        style: pw.TextStyle(
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ],
    );
  }

  static pw.Widget _buildSummaryCard(
    String label,
    String value,
    PdfColor color,
  ) {
    return pw.Column(
      children: [
        pw.Text(label, style: pw.TextStyle(fontSize: 10, color: grey600)),
        pw.SizedBox(height: 4),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildMaintenanceTable(List<MaintenanceEntry> entries) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'MAINTENANCE HISTORY',
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
            color: primaryColor,
          ),
        ),
        pw.SizedBox(height: 12),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey300),
          columnWidths: {
            0: const pw.FlexColumnWidth(2),
            1: const pw.FlexColumnWidth(1.5),
            2: const pw.FlexColumnWidth(1.5),
            3: const pw.FlexColumnWidth(1),
            4: const pw.FlexColumnWidth(1),
          },
          children: [
            // Header
            pw.TableRow(
              decoration: pw.BoxDecoration(color: primaryColor),
              children: [
                _buildTableCell('Title', isHeader: true),
                _buildTableCell('Date', isHeader: true),
                _buildTableCell('Category', isHeader: true),
                _buildTableCell('Mileage', isHeader: true),
                _buildTableCell('Cost', isHeader: true),
              ],
            ),
            // Data rows
            ...entries.map((entry) {
              return pw.TableRow(
                decoration: pw.BoxDecoration(
                  color: entries.indexOf(entry) % 2 == 0
                      ? PdfColors.grey50
                      : PdfColors.white,
                ),
                children: [
                  _buildTableCell(entry.title),
                  _buildTableCell(DateFormat('dd/MM/yyyy').format(entry.date)),
                  _buildTableCell(entry.category),
                  _buildTableCell('${entry.mileage} km'),
                  _buildTableCell('${entry.cost.toStringAsFixed(2)} DT'),
                ],
              );
            }),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildTableCell(String text, {bool isHeader = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: isHeader ? 10 : 9,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: isHeader ? PdfColors.white : PdfColors.black,
        ),
      ),
    );
  }

  static pw.Widget _buildDetailedEntries(List<MaintenanceEntry> entries) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'DETAILED RECORDS',
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
            color: primaryColor,
          ),
        ),
        pw.SizedBox(height: 12),
        ...entries.map((entry) {
          return pw.Container(
            margin: const pw.EdgeInsets.only(bottom: 16),
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey300),
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      entry.title,
                      style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: pw.BoxDecoration(
                        color: PdfColor(
                          secondaryColor.red,
                          secondaryColor.green,
                          secondaryColor.blue,
                          0.2,
                        ),
                        borderRadius: pw.BorderRadius.circular(4),
                      ),
                      child: pw.Text(
                        entry.category,
                        style: pw.TextStyle(
                          fontSize: 9,
                          color: primaryColor,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 8),
                pw.Row(
                  children: [
                    pw.Text(
                      'Date: ${DateFormat('MMMM dd, yyyy').format(entry.date)}',
                      style: pw.TextStyle(fontSize: 9, color: grey600),
                    ),
                    pw.SizedBox(width: 16),
                    pw.Text(
                      'Mileage: ${entry.mileage} km',
                      style: pw.TextStyle(fontSize: 9, color: grey600),
                    ),
                    pw.SizedBox(width: 16),
                    pw.Text(
                      'Cost: ${entry.cost.toStringAsFixed(2)} DT',
                      style: pw.TextStyle(
                        fontSize: 9,
                        color: secondaryColor,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                if (entry.description.isNotEmpty) ...[
                  pw.SizedBox(height: 8),
                  pw.Text(
                    'Description:',
                    style: pw.TextStyle(
                      fontSize: 9,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    entry.description,
                    style: const pw.TextStyle(fontSize: 9),
                  ),
                ],
                if (entry.recommendations.isNotEmpty) ...[
                  pw.SizedBox(height: 8),
                  pw.Text(
                    'Recommendations:',
                    style: pw.TextStyle(
                      fontSize: 9,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    entry.recommendations,
                    style: const pw.TextStyle(fontSize: 9),
                  ),
                ],
              ],
            ),
          );
        }),
      ],
    );
  }

  static pw.Widget _buildFooter(pw.Context context) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      margin: const pw.EdgeInsets.only(top: 16),
      child: pw.Text(
        'Page ${context.pageNumber} of ${context.pagesCount}',
        style: pw.TextStyle(fontSize: 10, color: grey600),
      ),
    );
  }
}
