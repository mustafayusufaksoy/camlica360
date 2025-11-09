import SwiftUI

// MARK: - Table Column Definition

struct TableColumn: Identifiable, Equatable {
    let id = UUID()
    let title: String
    let key: String
    let width: CGFloat?
    let sortable: Bool

    init(title: String, key: String, width: CGFloat? = nil, sortable: Bool = true) {
        self.title = title
        self.key = key
        self.width = width
        self.sortable = sortable
    }

    static func == (lhs: TableColumn, rhs: TableColumn) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Data Table Component

struct DataTable<Data: Identifiable, RowContent: View>: View {
    let columns: [TableColumn]
    let data: [Data]
    let rowContent: (Data) -> RowContent

    @State private var sortColumn: String?
    @State private var sortAscending: Bool = true

    init(
        columns: [TableColumn],
        data: [Data],
        @ViewBuilder rowContent: @escaping (Data) -> RowContent
    ) {
        self.columns = columns
        self.data = data
        self.rowContent = rowContent
    }

    var body: some View {
        VStack(spacing: 0) {
            // Table header
            headerView

            Divider()

            // Table rows
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(data) { item in
                        VStack(spacing: 0) {
                            rowContent(item)
                            Divider()
                        }
                    }
                }
            }
        }
    }

    private var headerView: some View {
        HStack(spacing: 0) {
            ForEach(columns) { column in
                headerColumn(column)

                if column != columns.last {
                    Divider()
                        .frame(height: 20)
                }
            }
        }
        .background(AppColors.neutral50)
    }

    private func headerColumn(_ column: TableColumn) -> some View {
        Button(action: {
            if column.sortable {
                if sortColumn == column.key {
                    sortAscending.toggle()
                } else {
                    sortColumn = column.key
                    sortAscending = true
                }
            }
        }) {
            HStack(spacing: 4) {
                Text(column.title)
                    .font(AppFonts.xsRegular)
                    .foregroundColor(AppColors.neutral700)

                if column.sortable {
                    sortIcon(for: column)
                }
            }
            .frame(
                minWidth: column.width,
                maxWidth: column.width ?? .infinity,
                alignment: .leading
            )
            .padding(.horizontal, AppSpacing.sm)
            .padding(.vertical, AppSpacing.md)
        }
        .buttonStyle(.plain)
    }

    private func sortIcon(for column: TableColumn) -> some View {
        let iconName: String
        if sortColumn == column.key {
            iconName = sortAscending ? "chevron.up" : "chevron.down"
        } else {
            iconName = "chevron.up.chevron.down"
        }

        return Image(systemName: iconName)
            .font(.system(size: 8))
            .foregroundColor(AppColors.neutral500)
    }
}

// MARK: - Preview

#Preview {
    struct SampleData: Identifiable {
        let id = UUID()
        let name: String
        let value: String
    }

    let sampleData = [
        SampleData(name: "Item 1", value: "100"),
        SampleData(name: "Item 2", value: "200")
    ]

    let columns = [
        TableColumn(title: "Name", key: "name"),
        TableColumn(title: "Value", key: "value")
    ]

    return DataTable(columns: columns, data: sampleData) { item in
        HStack {
            Text(item.name)
                .frame(maxWidth: .infinity, alignment: .leading)
            Text(item.value)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, AppSpacing.sm)
        .padding(.vertical, AppSpacing.md)
    }
    .padding()
    .background(AppColors.white)
}
