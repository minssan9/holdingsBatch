package halla.holdings.batch;

import org.springframework.jdbc.core.BatchPreparedStatementSetter;

import java.sql.PreparedStatement;
import java.sql.SQLException;

public class InvBatch {
//    private int batchInsert(int batchSize, int batchCount, List<ItemJdbc> subItems) {
//        jdbcTemplate.batchUpdate("INSERT INTO ITEM_JDBC (`NAME`, `DESCRIPTION`) VALUES (?, ?)",
//                new BatchPreparedStatementSetter() {
//                    @Override
//                    public void setValues(PreparedStatement ps, int i) throws SQLException {
//                        ps.setString(1, subItems.get(i).getName());
//                        ps.setString(2, subItems.get(i).getDescription());
//                    }
//
//                    @Override
//                    public int getBatchSize() {
//                        return subItems.size();
//                    }
//                });
//        subItems.clear();
//        batchCount++;
//        return batchCount;
//    }
}
