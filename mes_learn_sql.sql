use mes_test_db;

select * from production_lines; -- dây chuyền sản xuất
select * from products; -- sản phẩm cần sản xuất
select * from machines; -- máy móc
select * from employees; -- nhân viên
select * from work_orders; -- lệnh sản xuất
select * from production_logs; -- nhật ký sản xuất

-- 3 lệnh sản xuất có số lượng kế hoạch lớn nhất chưa bị huỷ
select order_code, product_id, planned_quantity, status
from work_orders where status != 'CANCELLED'
order by planned_quantity desc limit 3;

-- Lệnh có số lượng kế hoạch từ 500 đến 1000
select * from work_orders
where planned_quantity between 500 and 1000;

-- Lệnh thuộc một trong hai trạng thái Bất kỳ
select * from work_orders
where status in ('COMPLETED', 'CANCELLED');

-- Tìm mã lệnh bắt đầu bằng WO-00
select * from work_orders
where order_code like 'WO-00%';

-- Nhân viên chưa được phân công dây chuyền
select * from employees
where line_id is null;

-- Phân loại lệnh sản xuất theo số lượng kế hoạch
select order_code, planned_quantity,
	case 
		when planned_quantity >= 1000 then 'LARGE'
        when planned_quantity >= 500 then 'MEDIUM'
        else 'SMALL'
	end as order_size
from work_orders;

start transaction;
update machines set status = 'IDLE' where id = 1;
rollback;

-- hiển thị mã lệnh, tên sản phẩm, tên dây chuyền sản xuất và số lượng sp theo kế hoạch
select wo.order_code, p.name as product_name, pl.name as line_name, wo.planned_quantity
from work_orders wo
join products p on wo.product_id = p.id
join production_lines pl on wo.line_id = pl.id;

-- inner join lấy phân giao nhau
-- left join lấy phần giao nhau và phần bên trái

-- Liệt kê tất cả máy và tổng số sản phẩm đạt chuẩn của từng máy, kể cả máy chưa từng sản xuất.
select m.code, m.name, coalesce(sum(plg.good_quantity), 0) as total_good_quantity from machines m
left join production_logs plg on m.id = plg.machine_id -- dùng left join để lấy cả máy chưa từng sx
group by m.id, m.code, m.name;

-- Tổng hợp số lượng sản xuất theo lệnh.
select
	wo.order_code,
    wo.planned_quantity,
    coalesce(sum(plg.good_quantity), 0) as total_good,
    coalesce(sum(plg.defect_quantity), 0) as total_defect
from work_orders wo
left join production_logs plg on wo.id = plg.work_order_id -- left join để lấy cả lệnh chưa được dùng để sx
group by wo.order_code, wo.planned_quantity;

-- Tìm các lệnh có tổng sản phẩm đạt chuẩn dưới 80% kế hoạch.
select
	wo.order_code,
    wo.planned_quantity,
    wo.status,
    coalesce(sum(plg.good_quantity), 0) as total_good
from work_orders wo
left join production_logs plg on wo.id = plg.work_order_id
where wo.status != 'CANCELLED' -- lọc trước khi gom nhóm
group by wo.id, wo.order_code, wo.planned_quantity -- gom nhóm
having total_good < wo.planned_quantity * 0.8; -- lọc sau khi gom nhóm

-- Tìm các lệnh có số lượng kế hoạch lớn hơn mức trung bình của tất cả lệnh.
select * from work_orders
where planned_quantity > (select avg(planned_quantity) from work_orders);

-- Tìm sản phẩm có ít nhất một lệnh sản xuất đã hoàn thành.
select p.id, p.name from products p
where exists (select 1 from work_orders wo where wo.product_id = p.id and wo.status = 'COMPLETED');

-- union => loại bỏ các dòng trùng
-- union all=> giữ nguyên các dòng trùng, cost less
-- đều cần cùng số cột và kiểu dữ liệu
select order_code, status from work_orders
where status = 'PLANNED'

union all

select order_code, status from work_orders
where status = 'COMPLETED';